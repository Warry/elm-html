module Html.Events
    ( onBlur, onFocus, onSubmit
    , onKeyUp, onKeyDown, onKeyPress
    , onClick, onDoubleClick
    , onMouseMove
    , onMouseDown, onMouseUp
    , onMouseEnter, onMouseLeave
    , onMouseOver, onMouseOut
    , on, onWithOptions, Options, defaultOptions
    , targetValue, targetChecked, keyCode
    ) where
{-|
It is often helpful to create an [Union Type][] so you can have many different kinds
of events as seen in the [TodoMVC][] example.

[Union Type]: http://elm-lang.org/learn/Union-Types.elm
[TodoMVC]: https://github.com/evancz/elm-todomvc/blob/master/Todo.elm

# Focus Helpers
@docs onBlur, onFocus, onSubmit

# Keyboard Helpers
@docs onKeyUp, onKeyDown, onKeyPress

# Mouse Helpers
@docs onClick, onDoubleClick, onMouseMove,
      onMouseDown, onMouseUp,
      onMouseEnter, onMouseLeave,
      onMouseOver, onMouseOut

# Custom Event Handlers
@docs on, targetValue, targetChecked, keyCode,
    onWithOptions, Options, defaultOptions
-}

import Html exposing (Attribute)
import Json.Decode as Json exposing (..)
import VirtualDom


{-| Create a custom event listener.

    import Json.Decode as Json

    onClick : a -> Event a
    onClick address =
        on "click"

You first specify the name of the event in the same format as with
JavaScript’s `addEventListener`. Next you give a JSON decoder, which lets
you pull information out of the event object. If that decoder is successful,
the resulting value is given to a function that creates a `Signal.Message`.
So in our example, we will send `()` to the given `address`.
-}
on : String -> Json.Decoder a -> Attribute a
on name decoder addr =
  VirtualDom.on
    name
    decoder
    (\msg -> Signal.message addr msg)


{-| Same as `on` but you can set a few options.
-}
onWithOptions : String -> Options -> Json.Decoder a -> Attribute a
onWithOptions name opts decoder addr =
  VirtualDom.onWithOptions
    name
    opts
    decoder
    (\msg -> Signal.message addr msg)


{-| Options for an event listener. If `stopPropagation` is true, it means the
event stops traveling through the DOM so it will not trigger any other event
listeners. If `preventDefault` is true, any built-in browser behavior related
to the event is prevented. For example, this is used with touch events when you
want to treat them as gestures of your own, not as scrolls.
-}
type alias Options =
    { stopPropagation : Bool
    , preventDefault : Bool
    }


{-| Everything is `False` by default.

    defaultOptions =
        { stopPropagation = False
        , preventDefault = False
        }
-}
defaultOptions : Options
defaultOptions =
  VirtualDom.defaultOptions


-- COMMON DECODERS

{-| A `Json.Decoder` for grabbing `event.target.value` from the triggered
event. This is often useful for input event on text fields.

    onInput : Signal.Address a -> (String -> a) -> Attribute a
    onInput address contentToValue =
        on "input" targetValue (\str -> Signal.message address (contentToValue str))
-}
targetValue : Json.Decoder String
targetValue =
  at ["target", "value"] string


{-| A `Json.Decoder` for grabbing `event.target.checked` from the triggered
event. This is useful for input event on checkboxes.

    onInput : Signal.Address a -> (Bool -> a) -> Attribute a
    onInput address contentToValue =
        on "input" targetChecked (\bool -> Signal.message address (contentToValue bool))
-}
targetChecked : Json.Decoder Bool
targetChecked =
  at ["target", "checked"] bool


{-| A `Json.Decoder` for grabbing `event.keyCode` from the triggered event.
This is useful for key events today, though it looks like the spec is moving
towards the `event.key` field for this someday.

    onKeyUp : Signal.Address a -> (Int -> a) -> Attribute a
    onKeyUp address handler =
        on "keyup" keyCode (\code -> Signal.message address (handler code))
-}
keyCode : Json.Decoder Int
keyCode =
  ("keyCode" := int)


-- MouseEvent

messageOn : String -> a -> Attribute a
messageOn name value =
  on name (Json.succeed value)


{-|-}
onClick : a -> Attribute a
onClick =
  messageOn "click"


{-|-}
onDoubleClick : a -> Attribute a
onDoubleClick =
  messageOn "dblclick"


{-|-}
onMouseMove : a -> Attribute a
onMouseMove =
  messageOn "mousemove"


{-|-}
onMouseDown : a -> Attribute a
onMouseDown =
  messageOn "mousedown"


{-|-}
onMouseUp : a -> Attribute a
onMouseUp =
  messageOn "mouseup"


{-|-}
onMouseEnter : a -> Attribute a
onMouseEnter =
  messageOn "mouseenter"


{-|-}
onMouseLeave : a -> Attribute a
onMouseLeave =
  messageOn "mouseleave"


{-|-}
onMouseOver : a -> Attribute a
onMouseOver =
  messageOn "mouseover"


{-|-}
onMouseOut : a -> Attribute a
onMouseOut =
  messageOn "mouseout"


-- KeyboardEvent

onKey : String -> (Int -> a) -> Attribute a
onKey name handler =
  on name (Json.map handler keyCode)


{-|-}
onKeyUp : (Int -> a) -> Attribute a
onKeyUp =
  onKey "keyup"


{-|-}
onKeyDown : (Int -> a) -> Attribute a
onKeyDown =
  onKey "keydown"


{-|-}
onKeyPress : (Int -> a) -> Attribute a
onKeyPress =
  onKey "keypress"


-- Simple Events

{-|-}
onBlur : a -> Attribute a
onBlur =
  messageOn "blur"


{-|-}
onFocus : a -> Attribute a
onFocus =
  messageOn "focus"


{-| Capture a [submit](https://developer.mozilla.org/en-US/docs/Web/Events/submit)
event with [`preventDefault`](https://developer.mozilla.org/en-US/docs/Web/API/Event/preventDefault)
in order to prevent the form from changing the page’s location. If you need
different behavior, use `onWithOptions` to create a customized version of
`onSubmit`.
-}
onSubmit : Decoder a -> Attribute a
onSubmit decoder =
  onWithOptions
    "submit"
    onSubmitOptions
    decoder


onSubmitOptions : Options
onSubmitOptions =
  { defaultOptions | preventDefault = True }
