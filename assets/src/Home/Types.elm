module Home.Types exposing (..)

import Animation
import Browser.Navigation as Nav
import Http
import RequestStatus exposing(Status(..))
import Topics.Request as Request exposing (Topic(..))

type Msg
  = Noop
  | TopicsReceived (Result Http.Error (List Topic))
  | Present Menu
  | Close Menu
  | Animate Animation.Msg

type alias Model =
  { navKey : Nav.Key
  , topics : Status Http.Error (List Topic)
  , spinner : Animation.State
  , menuViewer : Menu -> MenuActions
  }

type MenuActions
  = Show Menu
  | Hide

type Menu
  = TopicMenu Topic
  | None

type View
  = TopicList
