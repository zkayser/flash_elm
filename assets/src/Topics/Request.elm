module Topics.Request exposing (..)

import Decks.Decoder as Deck exposing (Deck)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)

type Topic =
  Topic Data

type alias Data =
  { title : String
  , id : Int
  , subTopics : List Topic
  , decks : List Deck
  }

topicDecoder : Decoder Topic
topicDecoder =
  Decode.succeed Data
    |> required "title" Decode.string
    |> required "id" Decode.int
    |> required "sub_topics" (Decode.list (Decode.lazy (\_ -> topicDecoder)))
    |> required "decks" (Decode.list Deck.decoder)
    |> Decode.map Topic

topicListDecoder : Decoder (List Topic)
topicListDecoder =
  Decode.field "data" (Decode.list topicDecoder)

getTopics : Http.Request (List Topic)
getTopics =
  Http.get "http://localhost:4000/api/topics" topicListDecoder

fetchTopics : (Result Http.Error (List Topic) -> msg) -> Cmd msg
fetchTopics resultToMsg =
  Http.send resultToMsg getTopics
