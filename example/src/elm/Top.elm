module Top exposing (main)

import Browser
import Main exposing (Model, Msg, init, update, view)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
