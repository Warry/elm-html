module TextReverser where

import Html exposing (Html, Attribute, text, div, input)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetValue)
import String
import VirtualDom


-- VIEW

view : String -> Html String
view string =
  div []
    [ stringInput string
    , reversedString string
    ]


reversedString : String -> Html String
reversedString string =
  div [ myStyle ] [ text (String.reverse string) ]


stringInput : String -> Html String
stringInput string =
  input
    [ placeholder "Text to reverse"
    , value string
    , on "input" targetValue
    , myStyle
    ]
    []


myStyle : Attribute a
myStyle =
  style
    [ ("width", "100%")
    , ("height", "40px")
    , ("padding", "10px 0")
    , ("font-size", "2em")
    , ("text-align", "center")
    ]


-- SIGNALS

actions : Signal.Mailbox String
actions =
  Signal.mailbox ""

main : Signal VirtualDom.Node
main =
  Signal.map (\m ->
    view m actions.address
  ) actions.signal
