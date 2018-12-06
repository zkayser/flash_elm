module Home.Page exposing (..)

import Animation exposing (px, turn)
import Browser.Navigation as Nav
import Colors.Palette as Palette
import Css exposing (..)
import Css.Animations as Animations exposing (Keyframes)
import Css.Transitions as Transitions exposing (transition)
import Home.Types exposing (Msg(..), Model)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attrs exposing (css, class)
import Http
import RequestStatus exposing(Status(..))
import Topics.Request as Request exposing (Topic(..))
import Views.Spinner as Spinner

initialModel : Nav.Key -> Model
initialModel navKey =
  { navKey = navKey
  , topics = Loading
  , spinner = Spinner.init
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
        , css
          [ displayFlex
          , justifyContent center
          , alignItems center
          , height (Css.rem 20)
          , width (Css.rem 20)
          , fontSize (Css.rem 1.5)
          , backgroundColor Palette.primary
          , color (Css.rgb 255 255 255)
          , topicCardTransitions
          , hover <|
            [ transform <| scale 1.05
            , borderRadius (Css.pct 100)
            , cursor pointer
            , opacity <| Css.num 0.5
            , property "filter" "drop-shadow(0 0 1rem black)"
            , topicCardTransitions
            ]
          ]
        ]
        [ text topic.title ]
    ]

topicCardTransitions : Style
topicCardTransitions =
  transition
    [ Transitions.filter 1000
    , Transitions.transform 1000
    , Transitions.borderRadius 1000
    , Transitions.opacity 1000
    ]

-- UPDATE
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    None -> ( model, Cmd.none )
    TopicsReceived (Ok topics) ->
      ( { model | topics = Loaded topics }, Cmd.none )
    TopicsReceived (Err error) ->
      ( { model | topics = Errored error }, Cmd.none )
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