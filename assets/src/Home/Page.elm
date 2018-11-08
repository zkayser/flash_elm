module Home.Page exposing (..)

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
import Views

type alias Model = 
  { message : String 
  , formTitle : String
  , createdMessage : String
  , key : Nav.Key
  , topics : TopicPresenter
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
  , topics = TopicPresenter 0 0 []
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
    , Element.padding 25
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
      [ Element.centerX
      , Palette.whiteFont
      , Font.size 24
      , Font.medium
      ] (Element.text (topicText model))
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
    TopicPresenter _ 0 _ -> "You don't have any topics yet."
    TopicPresenter current l list ->
      viewTopics <| TopicPresenter current l list 

viewTopics : TopicPresenter -> String
viewTopics (TopicPresenter current length list) =
  case List.drop current list of
    head :: _ -> head.topic
    _ -> 
      Debug.log ("This should never happen")
      ""

-- UPDATE

type Msg
  = SubmitForm
  | FormSubmitted (Result Http.Error String)
  | SetFormTitle String
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
      ( model, Cmd.none )
    ClickedLeft ->
      let
        newTopics =
          case model.topics of
            TopicPresenter _ 0 _ -> model.topics
            TopicPresenter current length list ->
              (changeCurrentTopic (-) current length) length list
      in
      ( { model | topics = newTopics }, Cmd.none )
    ClickedRight ->
      let
        newTopics =
          case model.topics of
            TopicPresenter _ 0 _ -> model.topics
            TopicPresenter current length list ->
              (changeCurrentTopic (+) current length) length list
      in
      ( { model | topics = newTopics }, Cmd.none )
    TopicsReceived (Ok topics) ->
      ( updateTopics model topics, Cmd.none )
    TopicsReceived (Err error) ->
      ( model, Cmd.none )


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
  { model | topics = newTopics }
