
import Html exposing (Html, img)
import Html.Attributes exposing (src, style)
import Time exposing (fps)
import Window
import VirtualDom


-- VIEW

view : Int -> Html a
view n =
  img
    [ src "http://elm-lang.org/imgs/yogi.jpg"
    , style
        [ ("width", toString n ++ "px")
        , ("height", toString n ++ "px")
        ]
    ]
    []


-- SIGNALS

size : Signal Int
size =
  fps 30
    |> Signal.foldp (+) 0
    |> Signal.map (\t -> round (200 + 100 * sin (degrees t / 10)))

-- SIGNALS

actions : Signal.Mailbox String
actions =
  Signal.mailbox ""

main : Signal VirtualDom.Node
main =
  Signal.map (\size ->
    view size actions.address
  ) size
