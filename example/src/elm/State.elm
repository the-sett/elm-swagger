module State exposing (Model, Msg(..), Page(..))

{-| Keeping the update structure flat for this simple application.
-}


type Msg
    = Toggle Bool
    | SwitchTo Page
    | NoOp


type Page
    = Typography
    | Buttons
    | Grid
    | Cards


type alias Model =
    { debug : Bool
    , page : Page
    }
