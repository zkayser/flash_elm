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
  { message : String 
  , formTitle : String
  , createdMessage : String
  , key : Nav.Key
  , topics : Status Http.Error TopicPresenter 
  , style : Animation.State
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
  { message = "You are now on the home page." 
  , formTitle = ""
  , createdMessage = ""
  , key = navKey
  , topics = Loading
  , style = Animation.style [ Animation.opacity 0.3 ]
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
    Loading -> viewLoading model
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
      , Events.onClick ClickedLeft 
      , Element.pointer
      ] (Element.html ( 
        Html.i 
          [ class "material-icons" 
          , Attrs.style "font-size" "3rem"
          ] [ Html.text "chevron_left" ] ) )
    , Element.el 
      ([ Element.centerX
      , Palette.whiteFont
      , Font.size 24
      , Font.medium 
      ] ++ List.map Element.htmlAttribute (Animation.render model.style)) (Element.text (topicText model))
    , Element.el
      [ Element.alignRight
      , Palette.whiteFont
      , Font.semiBold
      , Element.pointer
      , Events.onClick ClickedRight
      ] (Element.html ( 
        Html.i 
          [ class "material-icons" 
          , Attrs.style "font-size" "3rem"
          ] [ Html.text "chevron_right" ] ) ) 
    ]

topicText : Model -> String
topicText model =
  case model.topics of
    Loaded topicPresenter ->
      case topicPresenter of
        TopicPresenter _ 0 _ -> "You don't have any topics yet."
        TopicPresenter current l list ->
          viewTopics <| TopicPresenter current l list 
    _ -> ""

viewTopics : TopicPresenter -> String
viewTopics (TopicPresenter current length list) =
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

viewLoading : Model -> Element Msg
viewLoading model =
  Element.el
    [ Element.centerX
    , Element.centerY 
    ] (Spinner.view model.spinner)

-- UPDATE

type Msg
  = SubmitForm
  | FormSubmitted (Result Http.Error String)
  | SetFormTitle String
  | Animate Animation.Msg
  | AddTopic
  | TopicsReceived (Result Http.Error (List Topic))
  | ClickedLeft
  | ClickedRight

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SubmitForm -> 
      let
          newModel =
            { model | formTitle = "" }
      in
      ( newModel, Http.send FormSubmitted (submitFormRequest model) )
    SetFormTitle string -> 
      let
          newModel =
            { model | formTitle = string }
      in
      ( newModel, Cmd.none )
    FormSubmitted (Err error) ->
        ( model, Cmd.none)
    FormSubmitted (Ok payload) ->
        let
            newModel =
              { model |
                createdMessage = "You created a new topic: " ++ payload } 
        in
        ( newModel, Cmd.none )
    AddTopic ->
      let
            newStyle =
              Animation.interrupt
                [ Animation.toWith
                  (Animation.easing
                      { duration = 2000.0 
                      , ease = (\x -> x ^ 2.0) 
                      }
                  )
                  [ Animation.opacity 1.0 ]
                ]
                model.style
      in
      ( { model | style = newStyle }, Cmd.none )
    ClickedLeft ->
      let
        newTopics =
          case model.topics of
            Loaded presenter ->
              case presenter of
                TopicPresenter _ 0 _ -> model.topics
                TopicPresenter current length list ->
                  Loaded <| (changeCurrentTopic (-) current length) length list
            _ -> model.topics
      in
      ( { model | topics = newTopics }, Cmd.none )
    ClickedRight ->
      let
        newTopics =
          case model.topics of
            Loaded presenter ->
              case presenter of
                TopicPresenter _ 0 _ -> model.topics
                TopicPresenter current length list ->
                  Loaded <| (changeCurrentTopic (+) current length) length list
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
            { model |
              style = Animation.update animMsg model.style
            , spinner = Spinner.update model animMsg
            }
      in
      ( newModel, Cmd.none )


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Animation.subscription Animate [ model.style, model.spinner ]


-- REQUEST
submitFormRequest : Model -> Http.Request String
submitFormRequest model =
  let
      jsonBody =
        Json.Encode.object
          [ ( "name", Json.Encode.string model.formTitle ) ]
          |> Http.jsonBody
      _ =
        Debug.log ("Http.post: ") (Http.post <| apiUrl ++ "/topics")
  in
  Json.Decode.field "topic" Json.Decode.string
    |> Http.post (apiUrl ++ "/topics") jsonBody

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
