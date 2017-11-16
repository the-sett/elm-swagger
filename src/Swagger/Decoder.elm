module Swagger.Decoder exposing (decoder)

{-| Decoders for Swagger Specs.

@docs decoder

-}

import Dict exposing (Dict)
import Json.Decode
    exposing
        ( Decoder
        , andThen
        , bool
        , fail
        , field
        , float
        , int
        , keyValuePairs
        , lazy
        , list
        , map
        , map2
        , maybe
        , nullable
        , oneOf
        , string
        , succeed
        , value
        )
import Json.Decode.Pipeline exposing (custom, decode, hardcoded, optional, required)
import Swagger.Model exposing (..)


defaultSpec : Spec
defaultSpec =
    { info = Nothing
    , servers = Nothing
    , security = Nothing
    , paths = Nothing
    , tags = Nothing
    , externalDocs = Nothing
    , components = Nothing
    , ext = Dict.empty
    }


{-| Decodes a Swagger Spec from json.
-}
decoder : Decoder Spec
decoder =
    map (\_ -> defaultSpec) string
