module Home.Types exposing (..)

import Animation
import Browser.Navigation as Nav
import Http
import RequestStatus exposing(Status(..))
import Topics.Request as Request exposing (Topic(..))

type Msg
  = None
  | TopicsReceived (Result Http.Error (List Topic))
  | Animate Animation.Msg

type alias Model =
  { navKey : Nav.Key
  , topics : Status Http.Error (List Topic)
  , spinner : Animation.State
  }

type View
  = TopicList
