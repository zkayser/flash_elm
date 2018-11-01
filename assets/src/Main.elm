module Main exposing (..)

import Browser
import Browser.Events
import Browser.Navigation as Nav
import Element exposing (Element, Device, DeviceClass(..))
import Element.Background as Background
import Element.Events as Events
import Element.Font as Font
import Fonts
import Home.Page
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Colors.Palette as Palette
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
  ( model, Cmd.none )

-- VIEW

view : Model -> Browser.Document Msg
view model =
  let
      viewPage body =
        { title = "Title for page"
        , body = body
        }
  in
  case model.level of
    Redirect ->
      viewPage [ layout model (\_ _ -> Element.none) (\_ -> Ignored) {} ] 
    Home homeModel ->
      viewPage [ layout model (Home.Page.view) HomeMsg homeModel ]

layout : Model -> (subModel -> DeviceClass -> Element msg) -> (msg -> Msg) -> subModel -> Html Msg
layout model pageView toMsg subModel =
  Element.layout 
  []
  ( Element.column [ Element.width Element.fill, Element.spacing 16 ] 
      [ viewNavBar model 
      , Element.map toMsg (pageView subModel model.deviceClass)
      ] 
  )

viewNavBar : Model -> Element Msg
viewNavBar model =
  Element.row
    [ Element.alignTop
    , Background.color Palette.primary
    , Element.width Element.fill
    , Element.height (Element.px 80)
    , Element.padding 16
    ]
    [ Element.el
      [ Element.centerX
      , Element.centerY
      , Palette.whiteFont
      , Fonts.titleSize
      , Font.medium  
      ] ( Element.text "Flash")
    , viewNavBarLinks model
    ]

viewNavBarLinks : Model -> Element Msg
viewNavBarLinks model =
  case model.deviceClass of
    Phone ->
      Element.el
        [ Element.alignRight
        , Element.centerY
        , Palette.whiteFont
        , Fonts.titleSize
        , Font.bold
        , Events.onClick ToggleNavDropdown
        ] (Element.html (i [ class "material-icons"] [ Html.text "menu"] ))
    _ -> 
      Element.none

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
  Browser.Events.onResize WindowResize

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
