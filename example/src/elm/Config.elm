module Config exposing (Config, config, configDecoder)

{-| Defines the configuration that the authentication example needs to run.
This provides urls for the services with which it interacts. A default
configuration and a decoder for config as json are provided.

@docs Config, config, configDecoder

-}

import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (andMap, withDefault)


{-| Defines the configuration that the content editor needs to run.
-}
type alias Config =
    { authRoot : String
    }


{-| Provides a default configuration.
-}
config : Config
config =
    { authRoot = "http://localhost:9073/auth/"
    }


{-| Implements a decoder for the config as json.
-}
configDecoder : Decoder Config
configDecoder =
    Decode.succeed
        (\authRoot ->
            { authRoot = authRoot
            }
        )
        |> andMap (field "authRoot" Decode.string)
