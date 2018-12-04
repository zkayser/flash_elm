module Views.Spinner exposing (..)

import Animation exposing (px)
import Colors.Palette as Palette
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)

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
  Animation.style
    [ Animation.rotate (Animation.turn 0) ]

update : { model | spinner : Animation.State } -> Animation.Msg -> Animation.State
update model animMsg =
 Animation.update animMsg model.spinner

styles : List (Html.Styled.Attribute msg)
styles =
  [ css
    [ border3 (Css.px 5) solid (rgb 120 120 120)
    , borderTopColor Css.transparent
    , borderRadius (Css.rem 5)
    , position fixed
    , top (Css.pct 50)
    , left (Css.pct 50)
    , height (Css.rem 4)
    , width (Css.rem 4)
    ]
  ]