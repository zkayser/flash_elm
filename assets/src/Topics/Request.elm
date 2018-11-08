module Topics.Request exposing (..)

import Http
import Json.Decode as Decode exposing (Decoder)

type alias Topic = { topic : String }

topicDecoder : Decoder Topic
topicDecoder =
  Decode.map Topic
    (Decode.field "topic" Decode.string)

topicListDecoder : Decoder (List Topic)
topicListDecoder =
  Decode.field "data" (Decode.list topicDecoder)

getTopics : Http.Request (List Topic)
getTopics =
  Http.get "http://localhost:4000/api/topics" topicListDecoder

fetchTopics : (Result Http.Error (List Topic) -> msg) -> Cmd msg
fetchTopics resultToMsg =
  Http.send resultToMsg getTopics
