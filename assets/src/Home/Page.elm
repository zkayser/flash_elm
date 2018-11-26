module Home.Page exposing (..)

import Animation exposing (px, turn)
import Browser.Navigation as Nav
import Colors.Palette as Palette
import Element exposing (Element, DeviceClass(..))
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Fonts
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes as Attrs exposing (..)
import Http
import Json.Decode
import Json.Encode
import Topics.Request as Request
import RequestStatus exposing(Status(..))
import Views
import Views.Spinner as Spinner

type alias Model = 
  { key : Nav.Key
  , topics : Status Http.Error TopicPresenter 
  , spinner : Animation.State
  }

type TopicPresenter =
  TopicPresenter Int Int (List Topic)

type alias Config =
  { title : String
  , borderColor : Element.Color
  , addButtonColor : Element.Color
  }

type alias Topic = { topic : String }

initialModel : Nav.Key -> Model
initialModel navKey = 
  { key = navKey
  , topics = Loading
  , spinner = Spinner.init
  }

-- VIEW
view : Model -> DeviceClass ->  Element Msg
view model deviceClass =  
  case deviceClass of
    Phone -> viewPageLayout model
    Tablet -> viewPageLayout model
    Desktop -> viewPageLayout model
    BigDesktop -> viewPageLayout model

viewPageLayout : Model -> Element Msg
viewPageLayout model =
  Element.wrappedRow
    [ Element.height (Element.px 512)
    , Element.width Element.fill
    , Element.paddingXY 100 25
    , Element.spacing 50
    ] 
    [ viewContainer model 
        { borderColor = Palette.primaryLight
        , title = "Topics" 
        , addButtonColor = Palette.secondaryDark
        }
    ]

viewContainer : Model -> Config -> Element Msg
viewContainer model config =
    Element.column
      [ Background.color config.borderColor
        , Element.height Element.fill
        , Element.width Element.fill
        , Border.shadow {
            offset = ( 2.0, 2.0 )
          , size = 2.0
          , blur = 4.0
          , color = Element.rgba 0.2 0.2 0.2 0.5
          }
        , Element.padding 16
      ]  
      [ viewContainerTitleRow model config
      , viewContainerBody model config
      ]
 

viewContainerTitleRow : Model -> Config -> Element Msg
viewContainerTitleRow model config =
  Element.row 
    [ Element.height (Element.px 48)
    , Element.width Element.fill
    , Element.alignTop
    ]
    [ Element.el
      [ Element.centerY
      , Element.centerX
      , Fonts.titleSize
      , Font.medium
      , Palette.whiteFont
      ] ( Element.text config.title )
    , Input.button
      [ Background.color config.addButtonColor
      , Border.shadow
        { offset = ( 2.0, 2.0 )
        , size = 1.0
        , blur = 4.0
        , color = Element.rgba 0.2 0.2 0.2 0.5
        }
      , Element.centerY
      , Element.alignRight
      , Border.rounded 100
      , Element.moveDown 1.5
      , Palette.whiteFont
      ]
      { onPress = Just AddTopic
      , label = Element.html ( Html.i [ class "material-icons" ] [ Html.text "add" ] )
      }
    ]


viewContainerBody : Model -> Config -> Element Msg
viewContainerBody model config =
  case model.topics of
    Loading -> Spinner.view model
    Errored httpError -> viewError httpError
    Loaded _ -> viewTopicsBody model
    _ -> Element.none

viewTopicsBody : Model -> Element Msg
viewTopicsBody model =
  Element.row
    [ Element.height (Element.px 48)
    , Element.width Element.fill
    , Element.centerY
    , Element.centerX
    , Element.moveUp 48.0
    ]
    [ Element.el
      [ Element.alignLeft
      , Palette.whiteFont
      , Font.semiBold
      , Events.onClick <| Clicked Left 
      , Element.pointer
      ] (Element.html ( 
        Html.i 
          [ class "material-icons" 
          , Attrs.style "font-size" "3rem"
          ] [ Html.text "chevron_left" ] ) )
    , Element.el 
      [ Element.centerX
      , Palette.whiteFont
      , Font.size 24
      , Font.medium 
      ] (viewTopics model)
    , Element.el
      [ Element.alignRight
      , Palette.whiteFont
      , Font.semiBold
      , Element.pointer
      , Events.onClick <| Clicked Right
      ] (Element.html ( 
        Html.i 
          [ class "material-icons" 
          , Attrs.style "font-size" "3rem"
          ] [ Html.text "chevron_right" ] ) ) 
    ]

viewTopic : TopicPresenter -> Element Msg
viewTopic topicPresenter =
  case topicPresenter of
    TopicPresenter _ 0 _ -> Element.text "You don't have any topics yet."
    TopicPresenter current l list -> Element.text (viewTopicTitle <| TopicPresenter current l list)

viewTopics : Model -> Element Msg
viewTopics model =
  RequestStatus.viewResource model.topics model viewError viewTopic

viewTopicTitle : TopicPresenter -> String
viewTopicTitle (TopicPresenter current length list) =
  case List.drop current list of
    head :: _ -> head.topic
    _ -> 
      Debug.log ("This should never happen")
      ""

viewError : Http.Error -> Element Msg
viewError httpError =
  Element.el 
    [ Element.centerX
    , Element.centerY
    ] (Element.text "Could not load topics")

-- UPDATE
type Direction = Right | Left

type Msg
  = SubmitForm
  | Animate Animation.Msg
  | AddTopic
  | TopicsReceived (Result Http.Error (List Topic))
  | Clicked Direction

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SubmitForm -> 
      ( model, Cmd.none )
    AddTopic ->
      ( model, Cmd.none )
    Clicked direction ->
      let
          operation =
            case direction of
              Right -> (+)
              Left -> (-)
          newTopics =
            case model.topics of
              Loaded presenter ->
                case presenter of
                  TopicPresenter _ 0 _ -> model.topics
                  TopicPresenter current length list ->
                    Loaded <| (changeCurrentTopic operation current length) length list
              _ -> model.topics
      in
      ( { model | topics = newTopics }, Cmd.none )
    TopicsReceived (Ok topics) ->
      ( updateTopics model topics, Cmd.none )
    TopicsReceived (Err error) ->
      let
        newTopics =
          Errored error
      in
      ( { model | topics = newTopics } , Cmd.none )
    Animate animMsg ->
      let
          newModel =
            { model | spinner = Spinner.update model animMsg }
      in
      ( newModel, Cmd.none )


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Animation.subscription Animate [ model.spinner ]


-- REQUEST
fetchTopics : Cmd Msg
fetchTopics =
  Request.fetchTopics TopicsReceived

-- HELPERS & DATA (a lot of this would probably go into another module)

apiUrl : String
apiUrl =
  "http://localhost:4000/api"

changeCurrentTopic : (Int -> Int -> Int) -> Int -> Int -> (Int -> List Topic -> TopicPresenter)
changeCurrentTopic subtractOrAdd current length =
  case subtractOrAdd current 1 of
    newPosition ->
      if newPosition < 0 then
        TopicPresenter (length - 1)
      else if newPosition == length then
        TopicPresenter 0
      else 
        TopicPresenter newPosition

updateTopics : Model -> List Topic -> Model
updateTopics model topics =
  let
      newTopics =
        TopicPresenter 0 (List.length topics) topics
  in
  { model | topics = Loaded newTopics }
