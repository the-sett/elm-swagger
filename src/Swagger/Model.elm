module Swagger.Model exposing (..)

import Dict exposing (Dict)
import Json.Decode
import Json.Encode as Encode
import JsonSchema exposing (Schema)


type alias Spec =
    { swagger : Maybe String
    , info : Maybe Info
    , basePath : Maybe String
    , tags : List Tag
    , path : Dict String Path
    , definitions : Dict String Schema
    }


type alias Tag =
    { name : Maybe String
    }


type alias Info =
    {}


type alias Path =
    { get : Maybe PathGet
    , post : Maybe PathPost
    }


type alias PathCommon a =
    { a
        | tags : List String
        , summary : Maybe String
        , description : Maybe String
        , operationId : Maybe String
        , consumes : List String
        , produces : List String
        , parameters : List Parameter
        , responses : Dict String Response
    }


type alias PathGet =
    PathCommon {}


type alias PathPost =
    PathCommon {}


type alias Parameter =
    { in_ : Maybe String
    , name : Maybe String
    , description : Maybe String
    , required : Maybe Bool
    , type_ : Maybe String
    , schema : Maybe Schema
    }


type alias Response =
    { description : Maybe String
    , type_ : Maybe String
    , schema : Maybe Schema
    }
