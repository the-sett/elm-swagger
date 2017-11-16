module Swagger.Model exposing (..)

import Dict exposing (Dict)
import EveryDict exposing (EveryDict)
import Json.Decode
import Json.Encode as Encode
import JsonSchema exposing (Schema)


{-| Data types used in the spec and mapping to Elm:

    integer  integer int32 signed 32 bits | Int
    long     integer int64 signed 64 bits | String
    float    number  float  | Float
    double   number  double | String
    string   string  | String
    byte     string  byte base64 encoded characters | String
    binary   string  binary any sequence of octets | String
    boolean  boolean | Bool
    date     string  date As defined by full-date - RFC3339 | String
    dateTime string  date-time As defined by date-time - RFC3339 | String
    password string  password A hint to UIs to obscure input. | String

-}



-- swagger : "2.0"
-- openapi : "3.0.0"


type Version
    = Swager_2_0
    | OpenApi_3_0_0


type alias Spec =
    { info : Maybe Info
    , servers : Maybe Servers
    , security : Maybe Security
    , paths : Maybe Paths
    , tags : Maybe Tags
    , externalDocs : Maybe ExternalDocs
    , components : Maybe Components
    , ext : Dict String String
    }


type alias Info =
    {}



-- basePath : Maybe String


type alias Servers =
    {}


type alias Security =
    {}


type alias Paths =
    { path : Dict String (Dict HttpVerb Path)
    }


type HttpVerb
    = Get
    | Post


type alias Path =
    { tags : List String
    , summary : Maybe String
    , description : Maybe String
    , operationId : Maybe String
    , consumes : List String
    , produces : List String
    , parameters : List Parameter
    , responses : Dict String Response
    }


type alias Tags =
    { tags : List Tag
    }


type alias Tag =
    { name : Maybe String
    }


type alias ExternalDocs =
    {}


type alias Components =
    { responses : Maybe Responses
    , parameters : Maybe Parameters
    , examples : Maybe Examples
    , requestBodies : Maybe RequestBodies
    , headers : Maybe Headers
    , links : Maybe Links
    , callbacks : Maybe Callbacks
    , schemas : Maybe Schemas
    , securitySchemas : Maybe SecuritySchemas
    }


type alias Responses =
    {}


type alias Response =
    { description : Maybe String
    , type_ : Maybe String
    , schema : Maybe Schema
    }


type alias Parameters =
    {}


type ParamIn
    = QueryParam
    | HeaderParam
    | PathParam
    | CookieParam


type alias Parameter =
    { in_ : Maybe ParamIn
    , name : Maybe String
    , description : Maybe String
    , required : Maybe Bool
    , type_ : Maybe String
    , schema : Maybe Schema
    }


type alias Examples =
    {}


type alias RequestBodies =
    {}


type alias Headers =
    {}


type alias Links =
    {}


type alias Callbacks =
    {}


type alias Schemas =
    {}


type alias SecuritySchemas =
    { userSecurity : Maybe UserSecurity
    , apiKey : Maybe APIKey
    }


type alias UserSecurity =
    {}


type alias APIKey =
    {}
