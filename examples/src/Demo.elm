module Demo where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (..)
import VirtualDom


type alias Model
  = (Int, Int)

type Action
  = NoOp
  | Left ItemAction
  | Right ItemAction
  | Reset

type ItemAction
  = Inc
  | Dec


initialModel = (0, 0)


view : Model -> Html Action
view (left, right) addr = addr |> -- Extract the address from the Html msg
  div []
    [ Html.map Left (viewItem left addr)
    , Html.map Right (lazy2 viewItem right addr)
    ]


viewItem : Int -> Signal.Address Action -> Html ItemAction
viewItem model addr =
  div []
    [ button [ onClick Dec ] [ text "-" ]
    , text (toString model)
    , button [ onClick Inc ] [ text "+" ]
    -- Use that address :
    , Html.forward addr
        (button [ onClick Reset ] [ text "reset all" ])
    ]



update : Action -> Model -> Model
update action (left, right) =
    case action of
      NoOp ->
        (left, right)

      Left a ->
        (updateItem a left, right)

      Right a ->
        (left, updateItem a right)

      Reset ->
        (0,0)


updateItem : ItemAction -> Int -> Int
updateItem action model =
    case action of
      Dec ->
        model - 1

      Inc ->
        model + 1


--


actions : Signal.Mailbox Action
actions =
  Signal.mailbox NoOp


model : Signal Model
model =
  Signal.foldp update initialModel actions.signal


main : Signal VirtualDom.Node
main =
  Signal.map (\m ->
    lazy view m actions.address
  ) model
