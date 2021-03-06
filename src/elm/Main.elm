import Effects exposing (Never)
import Pomodoro exposing (init, update, view, inputs, Model)
import StartApp
import Task
import Html exposing (Html)


app : StartApp.App Model
app =
    StartApp.start
        { init = init
        , update = update
        , view = view
        , inputs = inputs
        }


main : Signal Html
main =
    app.html


port tasks : Signal (Task.Task Never ())
port tasks =
    app.tasks
