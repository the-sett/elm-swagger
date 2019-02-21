module Json.Decode.Generic exposing
    ( Json(..), json
    , filter
    )

{-| Decodes JSON into a data model that is generic enough to describe any JSON.

The ability to only extract certain fields into the generic data model, is also
provided. This is useful in situations where some of the structure of a JSON model
is known, but there are also arbitrary extra fields that can be present and those
need to be extracted too.


# For working with any JSON.

@docs Json, json


# For filtering out patterns of extensible fields from JSON.

@docs filter

-}

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)


{-| A data structure describing the contents of any JSON.
-}
type Json
    = JString String
    | JBool Bool
    | JInt Int
    | JFloat Float
    | JNull
    | JObj (Dict String Json)
    | JArr (List Json)


string : Decoder Json
string =
    Decode.map JString Decode.string


bool : Decoder Json
bool =
    Decode.map JBool Decode.bool


int : Decoder Json
int =
    Decode.map JInt Decode.int


float : Decoder Json
float =
    Decode.map JFloat Decode.float


null : Decoder Json
null =
    Decode.null JNull


array : Decoder Json
array =
    Decode.list json
        |> Decode.map JArr


dict : Decoder Json
dict =
    Decode.dict json
        |> Decode.map JObj


filteredDict : (String -> Bool) -> Decoder Json
filteredDict match =
    Decode.dict json
        |> Decode.map (Dict.filter (\k _ -> match k))
        |> Decode.map JObj


{-| A JSON decoder that works with any JSON, decoding into the generic data model.
-}
json : Decoder Json
json =
    Decode.oneOf
        [ bool
        , int
        , float
        , null
        , string
        , Decode.lazy (\_ -> array)
        , Decode.lazy (\_ -> dict)
        ]


{-| A JSON decoder that works with any JSON, decoding into the generic data model.

If the JSON passed to this is an object, fields from that object will be extracted
only where the field names match the filter. Note that this filtering will only be
applied to the top-level object. Objects deeper inside the JSON will be decoded in
their entirety.

The expected use of this function is to pass it JSON with additional arbitrary fields
and a filter to match those fields. This should produce an object using the `JObj`
structure, that contains just those fields.

-}
filter : (String -> Bool) -> Decoder Json
filter match =
    Decode.oneOf
        [ bool
        , int
        , float
        , null
        , string
        , Decode.lazy (\_ -> array)
        , Decode.lazy (\_ -> filteredDict match)
        ]
