module Main exposing (..)

import Browser
import Browser.Events
import Browser.Navigation as Nav
import Colors.Palette as Palette
import Css exposing (..)
import Css.Global as Global exposing (global)
import Element exposing (Element, Device, DeviceClass(..))
import Element.Background as Background
import Element.Events as Events
import Element.Font as Font
import Fonts
import Home.Page
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onClick)
import Html.Styled.Attributes exposing (class, css)
import Styles exposing (globalStyles)
import Topics.Request as Request
import Url exposing (Url)

type alias Model =
  { deviceClass : DeviceClass
  , navBarDropdownState : DropdownState
  , level : ModelLevel
  }

type alias WindowSize =
  { width : Int
  , height : Int
  }

type ModelLevel
  = Redirect
  | Home Home.Page.Model

type DropdownState
  = Open
  | Closed

type alias Flags = WindowSize

-- MODEL

init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
  let
    device = Element.classifyDevice flags
    model =
      { deviceClass = device.class
      , navBarDropdownState = Closed
      , level = ( Home <| Home.Page.initialModel navKey)
      }
  in
  ( model, Cmd.map HomeMsg Home.Page.fetchTopics )

-- VIEW

view : Model -> Browser.Document Msg
view model =
  let
      viewPage body =
        { title = "Flash"
        , body = List.map toUnstyled ( body ++ globalStyles )
        }
  in
  case model.level of
    Redirect ->
      viewPage [ div [] [] ]
    Home homeModel ->
      viewPage (layout model Home.Page.view HomeMsg homeModel)

layout : Model -> (subModel -> Html msg) -> (msg -> Msg) -> subModel -> List (Html Msg)
layout model pageView toMsg subModel =
  viewHeader model :: [ Html.Styled.map toMsg (pageView subModel) ]

viewHeader : Model -> Html Msg
viewHeader model =
  header [ css Styles.navBar ] [ text "Flash" ]

-- UPDATE

type Msg
  = NoOp
  | Ignored
  | ToggleNavDropdown
  | WindowResize Int Int
  | HomeMsg Home.Page.Msg

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case (msg, model.level) of
    ( NoOp, _ ) -> ( model, Cmd.none )
    ( Ignored, _ ) -> ( model, Cmd.none )
    ( ToggleNavDropdown, _ ) ->
      let
          newDropdownState =
            case model.navBarDropdownState of
              Open -> Closed
              Closed -> Open
      in
      ( { model | navBarDropdownState = newDropdownState }, Cmd.none )
    ( WindowResize width height, _ ) ->
      let
          windowSize = { width = width, height = height }
      in
      ( { model | deviceClass = getDeviceClass windowSize }, Cmd.none )
    ( HomeMsg subMsg, Home subModel ) ->
      Home.Page.update subMsg subModel
        |> updateWith Home HomeMsg model
    ( _, _ ) -> ( model, Cmd.none )

updateWith : (subModel -> ModelLevel) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg) -> ( Model, Cmd Msg)
updateWith toModelLevel toMsg model ( subModel, subCmd ) =
  ( { model | level = toModelLevel subModel }, Cmd.map toMsg subCmd )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Browser.Events.onResize WindowResize
    , subscriptionsForPage model
    ]

subscriptionsForPage : Model -> Sub Msg
subscriptionsForPage model =
  case model.level of
    Home homeModel ->
      Sub.map HomeMsg (Home.Page.subscriptions homeModel)
    _ -> Sub.none

onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest request =
  NoOp

onUrlChange : Url -> Msg
onUrlChange url =
  NoOp

-- UTILITY FUNCTIONS
getDeviceClass : WindowSize -> DeviceClass
getDeviceClass =
  Element.classifyDevice >> .class

main =
  Browser.application {
      init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlRequest = onUrlRequest
    , onUrlChange = onUrlChange
    }
