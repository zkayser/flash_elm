module Views.Spinner exposing (..)

import Animation exposing (px)
import Colors.Palette as Palette
import Css exposing (..)
import Html.Styled exposing (..)

init : Animation.State
init =
 Animation.interrupt
   [ Animation.loop
     [ Animation.toWith (Animation.speed { perSecond = 8 })
       [ Animation.rotate (Animation.turn 1) ]
     , Animation.set [ Animation.rotate (Animation.turn 0) ]
     ]
   ]
   animationState

animationState : Animation.State
animationState =
 Animation.style [ Animation.rotate (Animation.turn 0) ]

update : { model | spinner : Animation.State } -> Animation.Msg -> Animation.State
update model animMsg =
 Animation.update animMsg model.spinner