module Demo where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import VirtualDom
import Html.Lazy exposing (..)

($) = Html.map

type alias Model
  = (Int, Int)

type Action
  = NoOp
  | Left ItemAction
  | Right ItemAction

type ItemAction
  = Inc
  | Dec


initialModel = (0, 0)


view : Model -> Html Action
view (left, right) =
  div []
    [ Left  $ lazy viewItem left
    , Right $ lazy viewItem right
    ]


viewItem : Int -> Html ItemAction
viewItem model =
  div []
    [ button [ onClick Dec ] [ text "-" ]
    , text (toString model)
    , button [ onClick Inc ] [ text "+" ]
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
    view m actions.address
  ) model
