module Home.Page exposing (..)

import Animation exposing (px, turn)
import Browser.Navigation as Nav
import Colors.Palette as Palette
import Css exposing (..)
import Css.Animations as Animations exposing (Keyframes, keyframes)
import Css.Transitions as Transitions exposing (transition)
import Home.Types exposing (Msg(..), Menu(..), MenuActions(..), Model)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attrs exposing (css, class)
import Html.Styled.Events exposing (onMouseEnter, onMouseLeave)
import Http
import RequestStatus exposing(Status(..))
import Topics.Request as Request exposing (Topic(..))
import Views.Spinner as Spinner

initialModel : Nav.Key -> Model
initialModel navKey =
  { navKey = navKey
  , topics = Loading
  , spinner = Spinner.init
  , menuViewer = menuViewer None
  }


-- VIEW
view : Model -> Html Msg
view model =
  case model.topics of
    Loading ->
      div
      (List.concat
        [ (List.map Attrs.fromUnstyled <| Animation.render model.spinner)
        , Spinner.styles
        ]
      )
      []
    Loaded topics -> viewTopics model topics
    Errored error -> div [] [ text "there was an error fetching topics" ]
    _ -> div [] []

viewTopics : Model -> List Topic -> Html Msg
viewTopics model topics =
  div [ class "grid-container" ] (List.map (viewTopic model) topics)

viewTopic : Model -> Topic -> Html Msg
viewTopic model (Topic topic) =
  div
    [ css
      [ displayFlex
      , justifyContent center
      , alignItems center
      , maxWidth <| Css.vw 100
      ]
    ]
    [  div
        [ class "card-panel animated-card"
        , onMouseEnter <| Present <| TopicMenu (Topic topic)
        , onMouseLeave <| Close <| TopicMenu (Topic topic)
        , css
          [ displayFlex
          , flexDirection column
          , justifyContent center
          , alignItems center
          , height (Css.rem 20)
          , width (Css.rem 20)
          , fontSize (Css.rem 1.5)
          , backgroundColor Palette.primary
          , color (Css.rgb 255 255 255)
          , topicCardTransitions
          , hover <|
            [ transform <| scale 1.2
            , borderRadius (Css.pct 100)
            , cursor pointer
            --, opacity <| Css.num 0.5
            , property "filter" "drop-shadow(0 0 1rem black)"
            , topicCardTransitions
            ]
          ]
        ]
        [ text topic.title
        , viewTopicCardMenu model (TopicMenu <| Topic topic)
        ]
    ]

topicCardTransitions : Style
topicCardTransitions =
  transition
    [ Transitions.filter 1000
    , Transitions.transform 1000
    , Transitions.borderRadius 1000
    --, Transitions.opacity 1000
    ]

viewTopicCardMenu : Model -> Menu -> Html Msg
viewTopicCardMenu model menu =
  case model.menuViewer menu of
    Show _ -> viewMenu model menu
    Hide -> text ""

viewMenu : Model -> Menu -> Html Msg
viewMenu model menu =
  div
  [ css
    [ border3 (Css.px 1) solid (Palette.secondary)
    , width <| Css.pct 120
    , height <| Css.pct 58
    , borderRadius4 Css.zero Css.zero (Css.rem 50) (Css.rem 50)
    , transform <| translateY <| Css.rem 4
    , overflow hidden
    , opacity <| Css.num 0
    , animationName (
        keyframes
          [ ( 0, [ Animations.opacity <| Css.num 0, Animations.transform [ scaleY 0 ] ] )
          , ( 50, [ Animations.opacity <| Css.num 0, Animations.transform [ scaleY 0.5, translateY <| Css.rem 2 ] ] )
          , ( 100, [ Animations.opacity <| Css.num 1, Animations.transform [ scaleY 1, translateY <| Css.rem 4] ] )
          ]
      )
    , property "animation-delay" "0ms"
    , property "animation-duration" "1000ms"
    , property "animation-fill-mode" "forwards"
    ]
  ]
  [ div
    [ css
      [ backgroundColor Palette.secondary
      , position absolute
      , width <| Css.pct 25
      , height <| Css.pct 100
      , displayFlex
      , justifyContent center
      ]
    ]
    [ text "+" ]
  , div
    [ css
      [ backgroundColor Palette.secondaryLight
      , position absolute
      , width <| Css.pct 25
      , height <| Css.pct 100
      , right <| Css.pct 50
      , displayFlex
      , justifyContent center
      ]
    ]
    [ text "-" ]
  , div
    [ css
      [ backgroundColor Palette.secondary
      , position absolute
      , width <| Css.pct 25
      , height <| Css.pct 100
      , right <| Css.pct 25
      , displayFlex
      , justifyContent center
      ]
    ]
    [ text "+" ]
  , div
    [ css
      [ backgroundColor Palette.secondaryLight
      , position absolute
      , width <| Css.pct 25
      , height <| Css.pct 100
      , right <| Css.pct 0
      , displayFlex
      , justifyContent center
      ]
    ]
    [ text "-" ]
  ]

-- UPDATE
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Noop -> ( model, Cmd.none )
    TopicsReceived (Ok topics) ->
      ( { model | topics = Loaded topics }, Cmd.none )
    TopicsReceived (Err error) ->
      ( { model | topics = Errored error }, Cmd.none )
    Present menuToView ->
      let
        newMenuViewer =
          menuViewer menuToView
      in
      ( { model | menuViewer = newMenuViewer }, Cmd.none )
    Close _ ->
      ( { model | menuViewer = menuViewer None }, Cmd.none )
    Animate animMsg ->
      ( { model | spinner = Spinner.update model animMsg }, Cmd.none )

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch [ Animation.subscription Animate [ model.spinner ] ]

-- REQUEST
fetchTopics : Cmd Msg
fetchTopics =
  Request.fetchTopics TopicsReceived

-- HELPERS
animToStyledAttrs : List (Html.Attribute msg) -> List (Attribute msg)
animToStyledAttrs unstyledAttrs =
  List.map Attrs.fromUnstyled unstyledAttrs

withAnimation : Animation.State -> List (Attribute msg) -> List (Attribute msg)
withAnimation animation otherStyles =
  (List.concat
    [ Animation.render animation |> animToStyledAttrs
    , otherStyles
    ]
  )

menuViewer : Menu -> Menu -> MenuActions
menuViewer menu1 menu2 =
  case menu1 of
    None -> Hide
    _ ->
      if menu1 == menu2 then Show menu1 else Hide