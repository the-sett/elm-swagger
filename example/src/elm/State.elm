module State exposing (Model, Msg(..), Page(..), ViewState(..))

import Http
import Json.Decode as Decode
import OpenApi.Model as OpenApi
import TheSett.Laf as Laf
import Url exposing (Url)


{-| Keeping the update structure flat for this simple application.
-}
type Msg
    = LafMsg Laf.Msg
    | Toggle Bool
    | SwitchTo Page
    | UpdateSpecUrl String
    | LoadSpec
    | TryAgain
    | FetchedApiSpec (Result Http.Error String)
    | NoOp


type Page
    = LoadSchema
    | EndPoints
    | DataModel



-- | FetchError
-- | DecodeError


type alias Model =
    { laf : Laf.Model
    , debug : Bool
    , page : Page
    , apiSpecPath : String
    , apiSpecUrl : Maybe Url
    , state : ViewState
    }


type ViewState
    = GetSpec
    | FetchError Http.Error
    | DecodeError Decode.Error
    | Loaded OpenApi.OpenApi
