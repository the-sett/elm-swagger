module OpenApi.SchemaBuilder exposing (Builder)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import JsonSchema exposing (Schema)


type alias Builder a =
    { schema : Schema
    , enocoder : a -> Encode.Value
    , decoder : Decoder
    }
