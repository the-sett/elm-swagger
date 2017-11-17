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


type alias Reference =
    { ref : String
    }


type alias Spec =
    { info : Maybe Info
    , servers : List Server
    , security : Maybe Security
    , paths : Dict String PathItem
    , tags : List Tag
    , externalDocs : Maybe ExternalDocs
    , components : Maybe Components
    , ext : Dict String String
    }



-- ======== Info Section ========


type alias Info =
    { title : Maybe String
    , description : Maybe String
    , termsOfService : Maybe String
    , contact : Maybe Contact
    , license : Maybe License
    , version : Maybe String
    }


type alias Contact =
    { name : Maybe String
    , url : Maybe String
    , email : Maybe String
    }


type alias License =
    { name : Maybe String
    , url : Maybe String
    }



-- ======== Servers section ========
-- basePath : Maybe String - this is a variable in 3.0.0, look for special variable when mapping to 2.0


type alias Server =
    { url : Maybe String
    , description : Maybe String
    , variables : Dict String ServerVariable
    }


type alias ServerVariable =
    { enum : List String
    , default : Maybe String
    , description : Maybe String
    }



-- ======== Security Section ========


type alias Security =
    {}



-- ======== Paths Section ========


type alias PathItem =
    { ref : Maybe String
    , summary : Maybe String
    , description : Maybe String
    , operations : Dict HttpVerb Operation
    , servers : List Server
    , parameters : List Parameter
    }


type HttpVerb
    = Get
    | Put
    | Post
    | Delete
    | Options
    | Head
    | Patch
    | Trace


type alias Operation =
    { tags : List String
    , summary : Maybe String
    , description : Maybe String
    , externalDocs : Maybe ExternalDocs
    , operationId : Maybe String
    , parameters : List Parameter
    , requestBody : Maybe RequestBody
    , responses : Dict String Response
    , callbacks : Dict String Callback
    , deprecated : Bool
    , security : Dict String (List String)
    , servers : List Server
    }



-- ======== Tags Section ========


type alias Tag =
    { name : Maybe String
    }



-- ======== ExternalDocs Section ========


type alias ExternalDocs =
    {}



-- ======== Components Section ========


type alias Components =
    { schemas : Dict String Schema
    , responses : Dict String Response
    , parameters : Dict String Parameter
    , examples : Dict String Example
    , requestBodies : Dict String RequestBody
    , headers : Dict String Header
    , links : Dict String Link
    , callbacks : Dict String Callback
    , securitySchemas : Dict String SecuritySchema
    }


type Schema
    = SchemaRef Reference
    | SchemaInline {}


type Response
    = ResponseRef Reference
    | ResponseInline
        { description : Maybe String
        , type_ : Maybe String
        , schema : Maybe Schema
        }


type ParamIn
    = QueryParam
    | HeaderParam
    | PathParam
    | CookieParam


type Style
    = Matrix
    | Label
    | Form
    | Simple
    | SpaceDelimited
    | PipeDelimited
    | DeepObject


type Parameter
    = ParameterRef Reference
    | ParameterInline
        { name : Maybe String
        , in_ : Maybe ParamIn
        , description : Maybe String
        , required : Maybe Bool
        , deprecated : Maybe Bool
        , allowEmptyValue : Maybe Bool
        , style : Maybe Style
        , explode : Maybe Bool
        , allowReserved : Maybe Bool
        , schema : Maybe Schema
        , example : Maybe String
        , examples : Dict String Example
        , content : Dict String MediaType
        }


type alias MediaType =
    { schema : Maybe Schema
    , example : String
    , examples : Dict String Example
    , encoding : Dict String Encoding
    }


type alias Encoding =
    { contentType : Maybe String
    , headers : Dict String Header
    , style : Maybe Style
    , explode : Maybe Bool
    , allowReserved : Maybe Bool
    }


type Example
    = ExampleRef Reference
    | ExampleInline
        { description : Maybe String
        , url : Maybe String
        }


type RequestBody
    = RequestBodyRef Reference
    | RequestBodyInline {}


type Header
    = HeaderRef Reference
    | HeaderInline {}


type Link
    = LinkRef Reference
    | LinkInline {}


type Callback
    = CallbackRef Reference
    | CallbackInline {}


type SecuritySchema
    = SecuritySchemaRef Reference
    | SecuritySchemaInline
        { userSecurity : Maybe UserSecurity
        , apiKey : Maybe APIKey
        }


type alias UserSecurity =
    {}


type alias APIKey =
    {}
