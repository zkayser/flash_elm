module Views.Spinner exposing (..)

import Animation exposing (turn, px)
import Colors.Palette as Palette
import Element exposing (Element)
import Element.Border as Border

view : { r | spinner : Animation.State } -> Element msg
view animationModel =
  Element.el
    [ Element.centerX
    , Element.centerY
    ] (viewSpinner animationModel.spinner)

viewSpinner : Animation.State -> Element msg
viewSpinner animation =
  Element.el
    ([ Element.height (Element.px 20)
    , Element.width (Element.px 20)
    , Border.rounded 50
    , Border.color Palette.secondary
    , Border.widthEach 
      { bottom = 0
      , right = 0
      , left = 0
      , top = 2
      }
    ] ++ List.map Element.htmlAttribute (Animation.render animation))  Element.none

init : Animation.State
init =
  Animation.interrupt
    [ Animation.loop 
      [ Animation.toWith (Animation.speed { perSecond = 8 })
        [ Animation.rotate (turn 1) ]
      , Animation.set [ Animation.rotate (turn 0) ]
      ]
    ]
    animationState

animationState : Animation.State
animationState =
  Animation.style [ Animation.rotate (turn 0) ]

update : { model | spinner : Animation.State } -> Animation.Msg -> Animation.State
update model animMsg =
  Animation.update animMsg model.spinner
