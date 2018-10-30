module Colors.Palette exposing (..)

import Element
import Element.Font as Font

primary : Element.Color
primary =
  Element.rgb255 103 58 183

primaryLight : Element.Color
primaryLight =
  Element.rgb255 154 103 234

primaryDark : Element.Color
primaryDark =
  Element.rgb255 50 11 134

secondary : Element.Color
secondary =
  Element.rgb255 77 208 225

secondaryLight : Element.Color
secondaryLight =
  Element.rgb255 136 255 255

secondaryDark : Element.Color
secondaryDark = 
  Element.rgb255 0 159 175

whiteFont : Element.Attribute msg
whiteFont =
  Font.color (Element.rgb 1 1 1)
