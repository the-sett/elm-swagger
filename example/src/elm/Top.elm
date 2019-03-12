module Top exposing (main)

--import Main exposing (Model, Msg, init, subscriptions, update, view)

import Browser
import LafMain exposing (Model, Msg, init, subscriptions, update, view)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
