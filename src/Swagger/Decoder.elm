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
import Json.Decode.Extra exposing (andMap, withDefault)
import Swagger.Model exposing (..)


defaultSpec : Swagger.Model.OpenApi
defaultSpec =
    { info = Nothing
    , servers = []
    , security = Nothing
    , paths = Dict.empty
    , tags = []
    , externalDocs = Nothing
    , components = Nothing
    , ext = Dict.empty
    }


{-| Decodes a Swagger Spec from json.
-}
decoder : Decoder Swagger.Model.OpenApi
decoder =
    map (\_ -> defaultSpec) string
