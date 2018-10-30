module Main exposing (..)

import Browser
import Browser.Events
import Browser.Navigation as Nav
import Element
import Home.Page
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Url exposing (Url)

type alias Model =
  { window : WindowSize
  , level : ModelLevel
  }

type alias WindowSize =
  { width : Int
  , height : Int
  }

type ModelLevel
  = Redirect
  | Home Home.Page.Model

type alias Flags = WindowSize

-- MODEL

init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
  let
    model =
      { window = flags
      , level = ( Home <| Home.Page.initialModel navKey)
      }
  in
  ( model, Cmd.none )

-- VIEW

view : Model -> Browser.Document Msg
view model =
  let
      viewPage toMsg body =
        { title = "Title for page"
        , body = List.map (Html.map toMsg) body
        }
  in
  case model.level of
    Redirect ->
      viewPage (\_ -> Ignored) [ layout model ]
    Home homeModel ->
      Debug.log ("You are viewing the home page")
      viewPage HomeMsg ( Home.Page.view homeModel ) 

layout : Model -> Html Msg
layout model =
  Element.layout []
    ( Element.row [] 
       [(Element.text "Hi there")] )

-- UPDATE

type Msg 
  = NoOp
  | Ignored
  | WindowResize Int Int
  | HomeMsg Home.Page.Msg

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case (msg, model.level) of
    ( NoOp, _ ) -> ( model, Cmd.none )
    ( Ignored, _ ) -> ( model, Cmd.none )
    ( WindowResize width height, _ ) ->
      let 
          windowSize = { width = width, height = height }
      in
      ( { model | window = windowSize }, Cmd.none )
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

main =
  Browser.application {
      init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlRequest = onUrlRequest
    , onUrlChange = onUrlChange
    }

