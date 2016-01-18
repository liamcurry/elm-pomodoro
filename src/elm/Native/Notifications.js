Elm.Native = Elm.Native || {};
Elm.Native.Notifications = {};
Elm.Native.Notifications.make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Notifications = localRuntime.Native.Notifications || {};

    if (localRuntime.Native.Notifications.values) {
        return localRuntime.Native.Notifications.values;
    }

    var Task = Elm.Native.Task.make(localRuntime);
    var Utils = Elm.Native.Utils.make(localRuntime);

    var canNotify = !!window.Notification

    var requestPermission = Task.asyncFunction(function (callback) {
        if (!canNotify) {
            return callback(Task.succeed(false));
        }

        if (Notification.permission === "granted") {
            return callback(Task.succeed(true));
        }

        Notification.requestPermission(function (status) {
            if (Notification.permission !== status) {
                Notification.permission = status;
            }
            var isGranted = status === "granted";
            return callback(Task.succeed(isGranted));
        });
    });

    var _new = function (title) {
        return Task.asyncFunction(function (callback) {
            if (!canNotify) {
                return callback(Task.succeed(Utils.Tuple0));
            }

            new Notification(title);

            return callback(Task.succeed(Utils.Tuple0));
        });
    };

    return {
        'requestPermission': requestPermission,
        'new': _new
    };
};
