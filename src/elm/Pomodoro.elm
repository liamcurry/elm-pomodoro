module Pomodoro (Model, init, Action, update, view) where

import Timer
import Effects exposing (Effects)
import Html exposing (..)
import Html.Events exposing (onClick)
import Time exposing (minute)


type alias Model =
    { timer : Timer.Model }


init : (Model, Effects Action)
init =
    let
        (timer, timerFx) = Timer.init
    in
        ( Model timer
        , timerFx
        )


type Action
    = Pomodoro
    | ShortBreak
    | LongBreak


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        Pomodoro ->
            let
                (timer, fx) = Timer.update (Timer.SetTime 25 * minute) model.timer
            in
                ({ model | timer = timer }, fx)
        ShortBreak ->
            let
                (timer, fx) = Timer.update (Timer.SetTime 5 * minute) model.timer
            in
                ({ model | timer = timer }, fx)
        LongBreak ->
            let
                (timer, fx) = Timer.update (Timer.SetTime 15 * minute) model.timer
            in
                ({ model | timer = timer }, fx)


view : Signal.Address Action -> Model -> Html
view address model =
    div []
        [ Timer.view address model.timer
        , button [ onClick address Timer.Start ] [ text "Start" ]
        , button [ onClick address Timer.Stop ] [ text "Stop" ]
        , button [ onClick address Timer.Reset ] [ text "Reset" ]
        ]
