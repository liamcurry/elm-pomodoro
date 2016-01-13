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
        , Effects.map TimerControl timerFx
        )


type Action
    = Pomodoro
    | ShortBreak
    | LongBreak
    | TimerControl Timer.Action


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        Pomodoro ->
            let
                (timer, fx) = Timer.update (Timer.SetTime (25 * minute)) model.timer
            in
                ({ model | timer = timer }
                , Effects.map TimerControl fx
                )
        ShortBreak ->
            let
                (timer, fx) = Timer.update (Timer.SetTime (5 * minute)) model.timer
            in
                ({ model | timer = timer }
                , Effects.map TimerControl fx
                )
        LongBreak ->
            let
                (timer, fx) = Timer.update (Timer.SetTime (15 * minute)) model.timer
            in
                ({ model | timer = timer }
                , Effects.map TimerControl fx
                )
        TimerControl act ->
            let
                (timer, fx) = Timer.update act model.timer
            in
                ({ model | timer = timer }
                , Effects.map TimerControl fx
                )


view : Signal.Address Action -> Model -> Html
view address model =
    div []
        [ div []
            [ a [ onClick address Pomodoro ] [ text "Pomodoro" ]
            , a [ onClick address ShortBreak ] [ text "Short Break" ]
            , a [ onClick address LongBreak ] [ text "Long Break" ]
            ]
        , Timer.view (Signal.forwardTo address TimerControl) model.timer
        , button [ onClick address (TimerControl Timer.Start) ] [ text "Start" ]
        , button [ onClick address (TimerControl Timer.Stop) ] [ text "Stop" ]
        , button [ onClick address (TimerControl Timer.Reset) ] [ text "Reset" ]
        ]
