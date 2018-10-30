module Fonts exposing (..)

import Element exposing (Attr)
import Element.Font as Font exposing (Font)

scaled : Int -> Int
scaled val =
  Element.modular 16 1.25 val |> round

regular : Attr decorative msg
regular =
  Font.size ( scaled 1 )

titleSize : Attr decorative msg
titleSize =
  Font.size ( scaled 5 )
