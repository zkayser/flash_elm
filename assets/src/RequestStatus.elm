module RequestStatus exposing (..)

type Status error success
  = NotRequested
  | Loading
  | Loaded success
  | Errored error

getData : Status error success -> Maybe success
getData status =
  case status of
    Loaded success -> Just success
    _ -> Nothing

getError : Status error success -> Maybe error
getError status =
  case status of
    Errored error -> Just error
    _ -> Nothing
