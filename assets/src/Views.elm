module Views exposing (..)

import Element exposing (Element)

filler : Int -> Element msg
filler portionSize =
  Element.el [ Element.width ( Element.fillPortion portionSize ) ] Element.none
