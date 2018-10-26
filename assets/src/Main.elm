module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Home.Page
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Url exposing (Url)

type Model
  = Redirect
  | Home Home.Page.Model

-- MODEL

init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init () url navKey =
  ( Home <| Home.Page.initialModel navKey, Cmd.none)

-- VIEW

view : Model -> Browser.Document Msg
view model =
  let
      viewPage toMsg body =
        { title = "Title for page"
        , body = List.map (Html.map toMsg) body
        }
  in
  case model of
    Redirect ->
      viewPage (\_ -> Ignored) [ div [] [ text "You should be redirected here"] ]
    Home homeModel ->
      Debug.log ("You are viewing the home page")
      viewPage HomeMsg ( Home.Page.view homeModel ) 

-- UPDATE

type Msg 
  = NoOp
  | Ignored
  | HomeMsg Home.Page.Msg

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case (msg, model) of
    ( NoOp, _ ) -> ( model, Cmd.none )
    ( Ignored, _ ) -> ( model, Cmd.none )
    ( HomeMsg subMsg, Home subModel ) -> 
      Home.Page.update subMsg subModel
        |> updateWith Home HomeMsg model
    ( _, _ ) -> ( model, Cmd.none )

updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg) -> ( Model, Cmd Msg)
updateWith toModel toMsg model ( subModel, subCmd ) =
  ( toModel subModel, Cmd.map toMsg subCmd )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

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

