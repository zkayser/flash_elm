module Colors.Palette exposing (..)

import Css exposing (rgb)
import Element
import Element.Font as Font

primary : Css.Color
primary =
  rgb 103 58 183

primaryLight : Css.Color
primaryLight =
  rgb 154 103 234

primaryDark : Css.Color
primaryDark =
  rgb 50 11 134

secondary : Css.Color
secondary =
  rgb 77 208 225

secondaryLight : Css.Color
secondaryLight =
  rgb 136 255 255

secondaryDark : Css.Color
secondaryDark = 
  rgb 0 159 175

whiteFont : Element.Attribute msg
whiteFont =
  Font.color (Element.rgb 1 1 1)
