module Timer where

import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (class)
import Time exposing (Time, inSeconds, inMinutes, minute)
import String exposing (padLeft)


type alias Model =
    { timeTotal : Time
    , timeLeft : Time
    , prevClockTime : Time
    , isRunning : Bool
    , doneMailbox : Signal.Mailbox Bool
    }


init : (Model, Effects Action)
init =
    ( { timeTotal = 5 * minute
    , timeLeft = 5 * minute
    , prevClockTime = 0
    , isRunning = False
    , doneMailbox = Signal.mailbox False
    }, Effects.none
    )


type Action
    = Start
    | Stop
    | Toggle
    | Reset
    | SetTime Time
    | Tick Time


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        Start ->
            ( { model | isRunning = True, prevClockTime = 0 }, Effects.tick Tick )
        Stop ->
            ( { model | isRunning = False }, Effects.none )
        Toggle ->
            if model.isRunning then
                ( { model | isRunning = False }, Effects.none )
            else
                ( { model | isRunning = True, prevClockTime = 0 }, Effects.tick Tick )
        Reset ->
            ( { model
              | timeLeft = model.timeTotal
              , isRunning = False
              }
            , Effects.none
            )
        SetTime timeTotal ->
            ( { model
              | timeTotal = timeTotal
              , timeLeft = timeTotal
              , isRunning = False
              }
            , Effects.none
            )
        Tick clockTime ->
            let
                elapsed =
                    if model.prevClockTime > 0 then
                        clockTime - model.prevClockTime
                    else
                        0
                timeLeft = max 0 (model.timeLeft - elapsed)
            in
                if model.isRunning then
                    if timeLeft > 0 then
                        ( { model
                          | timeLeft = timeLeft
                          , prevClockTime = clockTime
                          }
                        , Effects.tick Tick
                        )
                    else
                        let
                            task = Signal.send model.doneMailbox.address True
                        in
                            ( { model
                            | timeLeft = model.timeTotal
                            , prevClockTime = 0
                            , isRunning = False
                            }
                            , Effects.none
                            )
                else
                    ( model, Effects.none )


view : Signal.Address Action -> Model -> Html
view address model =
    let
        minutes = inMinutes model.timeLeft
            |> truncate
            |> toFloat
        seconds = model.timeLeft - minutes * minute
            |> inSeconds
            |> truncate
    in
        div [ class "timer" ]
            [ span
                [ class "timerMin" ]
                [ minutes
                    |> toString
                    |> text
                ]
            , span
                [ class "timerSep" ]
                [ text ":" ]
            , span
                [ class "timerSec" ]
                [ seconds
                    |> toString
                    |> padLeft 2 '0'
                    |> text
                ]
            ]
