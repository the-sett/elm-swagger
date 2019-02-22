module OpenApi.Encoder exposing (EncoderProgram, encode, encodeSpecProgram, encodeValue)

{-| Encoders for Swagger Specs.

@docs EncoderProgram, encode, encodeSpecProgram, encodeValue

-}

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Encode as Encode
import OpenApi.Model exposing (..)


type alias Spec =
    Swagger.Model.OpenApi


{-| Defines the type of programs that generate output over Swagger Specs.
-}
type alias EncoderProgram =
    Platform.Program Never () ()


{-| A program that outputs a Swagger Spec as json.
-}
encodeSpecProgram : Spec -> (String -> Cmd ()) -> EncoderProgram
encodeSpecProgram schema emit =
    Platform.worker
        { init = \_ -> ( (), emit (encode schema) )
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


{-| Encodes and formats a Swagger Spec as a json string.
-}
encode : Spec -> String
encode schema =
    Encode.encode 2 (encodeValue schema)


{-| Encodes a Swagger Spec as a json Value.
-}
encodeValue : Spec -> Encode.Value
encodeValue schema =
    Encode.string "swagger spec"
