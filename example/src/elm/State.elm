module State exposing (Model, Msg(..), Page(..))

{-| Keeping the update structure flat for this simple application.
-}


type Msg
    = Toggle Bool
    | SwitchTo Page
    | NoOp


type Page
    = EndPoints
    | DataModel


type alias Model =
    { debug : Bool
    , page : Page
    }
