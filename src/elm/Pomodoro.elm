module Pomodoro

    ( Model
    , Action
    , init
    , update
    , view
    , inputs
    ) where

import Timer
import Char
import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Keyboard
import Time exposing (minute)
import Notifications


type alias Model =
    { timer : Timer.Model
    , notificationsPermission : Notifications.Permission }


initialModel : Timer.Model -> Model
initialModel timer =
    { timer = timer
    , notificationsPermission = Notifications.Default
    }


init : (Model, Effects Action)
init =
    let
        (timer, timerFx) = Timer.init
        model = initialModel timer
    in
        ( model
        , Effects.map TimerAction timerFx
        )


type Action
    = NoOp
    | Pomodoro
    | ShortBreak
    | LongBreak
    | TimerAction Timer.Action
    | EnableNotifications
    | ChangeNotificationsPermission Bool


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp ->
            (model, Effects.none)
        Pomodoro ->
            let
                (timer, fx) = Timer.update (Timer.SetTime (25 * minute)) model.timer
            in
                ({ model | timer = timer }
                , Effects.map TimerAction fx
                )
        ShortBreak ->
            let
                (timer, fx) = Timer.update (Timer.SetTime (5 * minute)) model.timer
            in
                ({ model | timer = timer }
                , Effects.map TimerAction fx
                )
        LongBreak ->
            let
                (timer, fx) = Timer.update (Timer.SetTime (15 * minute)) model.timer
            in
                ({ model | timer = timer }
                , Effects.map TimerAction fx
                )
        TimerAction act ->
            let
                (timer, fx) = Timer.update act model.timer
            in
                ({ model | timer = timer }
                , Effects.map TimerAction fx
                )
        EnableNotifications ->
            let
                task = Notifications.requestPermission
                fx = Effects.task task
            in
                (model, Effects.map ChangeNotificationsPermission fx)
        ChangeNotificationsPermission permission ->
            ({ model | notificationsPermission = Notifications.Default }
            , Effects.none
            )


pageHeader : Html
pageHeader =
    header
        [ class "pageHeader layout horizontal justifyBetween center" ]
        [ h1 [ class "pageTitle" ] [ text "elm-pomodoro" ]
        , a [ href "https://github.com/liamcurry/elm-pomodoro" ] [ text "Github" ]
        ]


pageFooter : Signal.Address Action -> Html
pageFooter address =
    let
        kbShortcut bind desc =
            li [ ]
                [ kbd [ ] [ text bind ]
                , text desc
                ]
        kbShortcuts =
            div [ class "kbShortcuts box" ]
                [ h2 [ ] [ text "Keyboard Shortcuts" ]
                , ul [ ]
                    [ kbShortcut "SPACE" "Start or stop the timer"
                    , kbShortcut "ALT + P" "Pomodoro"
                    , kbShortcut "ALT + S" "Short Break"
                    , kbShortcut "ALT + L" "Long Break"
                    , kbShortcut "ALT + R" "Reset Timer"
                    ]
                ]
        notifications =
            div [ class "notifications box" ]
                [ h2 [ ] [ text "Notifications" ]
                , p [ ] [ text "Desktop Notifications are currently supported in Chrome, Firefox and Safari" ]
                , p [ ] [ small [ ] [ text "(Not fully implemented yet)" ] ]
                , button
                    [ onClick address EnableNotifications ]
                    [ text "Enable Desktop Alerts" ]
                ]
    in
        div [ class "layout horizontal equal" ]
            [ kbShortcuts
            , notifications
            ]


kbPressed : Bool -> Int -> Action
kbPressed isAltDown code =
    let
        char = Char.fromCode code
    in
        if isAltDown then
            case char of
                'π' -> Pomodoro
                'ß' -> ShortBreak
                '¬' -> LongBreak
                '®' -> TimerAction Timer.Reset
                _ -> NoOp
        else if char == ' ' then
            TimerAction Timer.Toggle
        else
            NoOp


inputs : List (Signal Action)
inputs =
    [ Signal.map2 kbPressed Keyboard.alt Keyboard.presses ]


view : Signal.Address Action -> Model -> Html
view address model =
    let
        btn act str = button [ onClick address act ] [ text str ]
        pomodoroControls =
            div [ class "pomodoroControls layout horizontal equal" ]
                [ btn Pomodoro "Pomodoro"
                , btn ShortBreak "Short Break"
                , btn LongBreak "Long Break"
                ]
        startBtn = btn (TimerAction Timer.Start) "Start"
        stopBtn = btn (TimerAction Timer.Stop) "Stop"
        timerControls =
            div [ class "timeControls layout horizontal equal" ]
                [ if model.timer.isRunning then stopBtn else startBtn
                , btn (TimerAction Timer.Reset) "Reset"
                ]
        pageContent =
            div [ class "pageContent" ]
                [ pomodoroControls
                , Timer.view (Signal.forwardTo address TimerAction) model.timer
                , timerControls
                ]
    in
        div [ class "container" ]
            [ pageHeader
            , pageContent
            , pageFooter address
            ]
