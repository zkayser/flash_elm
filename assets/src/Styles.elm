module Styles exposing (..)

import Css exposing (..)
import Css.Global as Global exposing (global)
import Html.Styled exposing (Html)
import Colors.Palette as Palette

globalStyles : List (Html msg)
globalStyles =
  [ global
    [ Global.html
      [ Css.minWidth (Css.pct 100)
      , Css.minHeight (Css.pct 100)
      , Css.maxWidth (Css.pct 100)
      ]
    , Global.body [ Css.margin (Css.px 0) ]
    ]
  ]

navBar : List Style
navBar =
  [ displayFlex
  , width (pct 100)
  , backgroundColor Palette.primary
  , height (Css.rem 4)
  , alignItems center
  , justifyContent center
  , color (rgb 255 255 255)
  , fontWeight bolder
  , fontSize (Css.rem 2.5)
  , fontFamily sansSerif
  , textTransform capitalize
  , boxShadow4 (px 0) (px 1) (px 10) (hex "999")
  ]