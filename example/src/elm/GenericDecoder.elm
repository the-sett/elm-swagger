module GenericDecoder exposing (Meta(..), meta)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)


type Meta
    = MString String
    | MBool Bool
    | MInt Int
    | MFloat Float
    | MNull
    | MObj (Dict String Meta)
    | MArr (List Meta)


string : Decoder Meta
string =
    Decode.map MString Decode.string


bool : Decoder Meta
bool =
    Decode.map MBool Decode.bool


int : Decoder Meta
int =
    Decode.map MInt Decode.int


float : Decoder Meta
float =
    Decode.map MFloat Decode.float


null : Decoder Meta
null =
    Decode.null MNull


array : Decoder Meta
array =
    Decode.list meta
        |> Decode.map MArr


dict : Decoder Meta
dict =
    Decode.dict meta
        |> Decode.map MObj


meta : Decoder Meta
meta =
    Decode.oneOf [ bool, int, float, null, string, Decode.lazy (\_ -> array), Decode.lazy (\_ -> dict) ]
