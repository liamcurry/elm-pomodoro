module Notifications where

import Task exposing (Task)
import Native.Notifications


type Permission
    = Default
    | Granted
    | Denied


requestPermission : Task x Bool
requestPermission = Native.Notifications.requestPermission


new : String -> Task error ()
new = Native.Notifications.new
