module Decks.Decoder exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)

type alias Deck =
  { id : Int
  , title : String
  }

decoder : Decoder Deck
decoder =
  Decode.succeed Deck
    |> required "id" Decode.int
    |> required "title" Decode.string
