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
      viewPage [ layout model (\_ _ -> div [] []) (\_ -> Ignored) {} ] 
    Home homeModel ->
      viewPage [ layout model (Home.Page.view) HomeMsg homeModel ]

globalStyles : List (Html Msg)
globalStyles =
  [ global
    [ Global.html
      [ Css.minWidth (Css.pct 100)
      , Css.minHeight (Css.pct 100)
      ]
    , Global.body
      [ Css.margin (Css.px 0) ]
    ]
  ]

layout : Model -> (subModel -> DeviceClass -> Html msg) -> (msg -> Msg) -> subModel -> Html Msg
layout model pageView toMsg subModel =
  header 
    [ css
      [ displayFlex
      , width (pct 100)
      , backgroundColor Palette.primary
      , height (Css.rem 4)
      , alignItems center
      , justifyContent center
      , color (rgb 255 255 255)
      , fontWeight bolder
      , fontSize (Css.rem 2.5)
      , fontFamily sansSerif
      , textTransform capitalize
      , boxShadow4 (px 0) (px 1) (px 10) (hex "999")
      ]
    ]
    [ text "Flash" ]

-- layout : Model -> (subModel -> DeviceClass -> Element msg) -> (msg -> Msg) -> subModel -> Html Msg
-- layout model pageView toMsg subModel =
--   Element.layout 
--   []
--   ( Element.column [ Element.width Element.fill, Element.spacing 16 ] 
--       [ viewNavBar model 
--       , Element.map toMsg (pageView subModel model.deviceClass)
--       ] 
--   )

-- viewNavBar : Model -> Element Msg
-- viewNavBar model =
--   Element.row
--     [ Element.alignTop
--     , Background.color Palette.primary
--     , Element.width Element.fill
--     , Element.height (Element.px 80)
--     , Element.padding 16
--     ]
--     [ Element.el
--       [ Element.centerX
--       , Element.centerY
--       , Palette.whiteFont
--       , Fonts.titleSize
--       , Font.medium  
--       ] ( Element.text "Flash")
--     , viewNavBarLinks model
--     ]

-- viewNavBarLinks : Model -> Element Msg
-- viewNavBarLinks model =
--   case model.deviceClass of
--     Phone ->
--       Element.el
--         [ Element.alignRight
--         , Element.centerY
--         , Palette.whiteFont
--         , Fonts.titleSize
--         , Font.bold
--         , Events.onClick ToggleNavDropdown
--         ] (Element.html (i [ class "material-icons"] [ Html.Styled.text "menu"] ))
--     _ -> 
--       Element.none

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
