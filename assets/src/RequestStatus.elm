module RequestStatus exposing (..)

import Animation
import Element exposing (Element)
import Views.Spinner as Spinner

type Status error success
  = NotRequested
  | Loading
  | Loaded success
  | Errored error

type alias LoadingView r = { r | spinner : Animation.State }

viewResource : Status error success -> LoadingView r -> (error -> Element msg) -> (success -> Element msg) -> Element msg
viewResource status loadingView errorViewFunction successViewFunction =
  case status of
    NotRequested -> Element.none
    Loading -> Spinner.view loadingView
    Loaded success -> successViewFunction success
    Errored error -> errorViewFunction error
