module Swagger.SchemaBuilder exposing (..)

import JsonSchema exposing (Schema)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Builder a =
    { schema : Schema
    , enocoder : a -> Encode.Value
    , decoder : Decoder
    }
