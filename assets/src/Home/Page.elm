module Home.Page exposing (..)

import Browser.Navigation as Nav
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode
import Json.Encode

type alias Model = 
  { message : String 
  , formTitle : String
  , createdMessage : String
  , key : Nav.Key
  }

type alias Topic = { topic : String }

initialModel : Nav.Key -> Model
initialModel navKey = 
  { message = "You are now on the home page." 
  , formTitle = ""
  , createdMessage = ""
  , key = navKey
  }

-- VIEW
view : Model -> List (Html Msg)
view model =
  [ div [ class "container" ]
    [ text model.message,
      Html.form [ class "form", onSubmit SubmitForm ] 
        [ input 
          [ placeholder "Title"
          , type_ "text"
          , value model.formTitle
          , onInput SetFormTitle
          , autocomplete False
          ]
          []
        ]
    , button [ onClick SubmitForm ] [ text "Submit" ]
    , div [] [ text model.createdMessage ]
    ]
  ]

-- UPDATE

type Msg
  = SubmitForm
  | FormSubmitted (Result Http.Error String)
  | SetFormTitle String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SubmitForm -> 
      let
          newModel =
            { model | formTitle = "" }
      in
      Debug.log ("Hit SubmitForm message: ")
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


