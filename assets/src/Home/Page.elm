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
  , topics : Status Http.Error (List Topic)
  , spinner : Animation.State
  , currentlyViewing : FlashData
  }

type FlashData = Topics | Decks

type alias Topic = { topic : String }

initialModel : Nav.Key -> Model
initialModel navKey = 
  { key = navKey
  , topics = Loading
  , spinner = Spinner.init
  , currentlyViewing = Topics
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
    [ Element.height (Element.px 256)
    , Element.width Element.fill
    , Element.paddingXY 100 25
    , Element.spacing 50
    ] (viewData model)

viewData : Model -> List (Element Msg)
viewData model =
  case model.currentlyViewing of
    Topics -> viewTopics model
    Decks -> [ Element.text "Hello. There should be decks here." ]
    
viewTopics : Model -> List (Element Msg)
viewTopics model =
  case model.topics of
    NotRequested -> [ Element.none ]
    Loading -> [ Spinner.view model ]
    Loaded topics -> viewTopicList topics
    Errored error -> [ viewError error ]

viewTopicList : List Topic -> List (Element Msg)
viewTopicList topics =
  case topics of
    [] -> [ Element.text "You don't have any topics yet."]
    _ ->
      List.map viewTopic topics

viewTopic : Topic -> Element Msg
viewTopic data =
  Element.el
    [ Background.color Palette.primary
    , Element.width (Element.px 320)
    , Element.height (Element.px 320)
    , Border.shadow {
      offset = ( 2.0, 2.0 )
    , size = 2.0
    , blur = 4.0
    , color = Element.rgba 0.2 0.2 0.2 0.5
    }
    , Palette.whiteFont
    , Font.size 24
    , Font.regular
    , Element.padding 16
    ] 
    ( Element.el [ Element.centerY, Element.centerX ] ( Element.text data.topic ) )

viewError : Http.Error -> Element Msg
viewError httpError =
  Element.el 
    [ Element.centerX
    , Element.centerY
    ] (Element.text "Could not load topics")

-- UPDATE
type Msg
  = SubmitForm
  | Animate Animation.Msg
  | AddTopic
  | TopicsReceived (Result Http.Error (List Topic))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SubmitForm -> 
      ( model, Cmd.none )
    AddTopic ->
      ( model, Cmd.none )
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

updateTopics : Model -> List Topic -> Model
updateTopics model topics =
  { model | topics = Loaded topics }
