--import Effects exposing (Never)
--import Pomodoro exposing (init, update, view)
--import Time exposing (minute)
--import StartApp
--import Task
import Html exposing (..)


{-
app =
    StartApp.start
        { init = init
        , update = update
        , view = view
        , inputs = []
        }


main =
    app.html


port tasks : Signal (Task.Task Never ())
port tasks =
    app.tasks
-}

main : Html
main =
    h1 [] [text "Hello!"]
