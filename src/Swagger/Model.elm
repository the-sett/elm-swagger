module Swagger.Model exposing (AnyOrExpression(..), Callback(..), Components, Contact, Discriminator, Encoding, Example(..), ExternalDocs, Header(..), HttpVerb(..), Info, License, Link(..), MediaType, OAuthFlow, OAuthFlows, OpenApi, Operation, ParamIn(..), Parameter(..), PathItem, Reference, RequestBody(..), Response(..), Schema(..), SecurityRequirement, SecurityScheme(..), SecurityTokenIn(..), Server, ServerVariable, Style(..), Tag, Version(..), Xml)

import Dict exposing (Dict)
import EveryDict exposing (EveryDict)
import Json.Decode
import Json.Encode as Encode exposing (Value)
import JsonSchema



{- The type definitions below are in alphabetical order to aid findin them. -}


type AnyOrExpression
    = Any Value
    | Expression String


type Callback
    = CallbackRef Reference
    | CallbackInline
        { expressions : Dict String PathItem
        }


type alias Components =
    { schemas : Dict String Schema
    , responses : Dict String Response
    , parameters : Dict String Parameter
    , examples : Dict String Example
    , requestBodies : Dict String RequestBody
    , headers : Dict String Header
    , links : Dict String Link
    , callbacks : Dict String Callback
    , securitySchemes : Dict String SecurityScheme
    }


type alias Contact =
    { name : Maybe String
    , url : Maybe String
    , email : Maybe String
    }


type alias Discriminator =
    { propertyName : Maybe String
    , mapping : Dict String String
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
        { summary : Maybe String
        , description : Maybe String
        , value : Maybe Value
        , externalValue : Maybe String
        }


type alias ExternalDocs =
    { description : Maybe String
    , url : Maybe String
    }


type Header
    = HeaderRef Reference
    | HeaderInline
        { description : Maybe String
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


type HttpVerb
    = Get
    | Put
    | Post
    | Delete
    | Options
    | Head
    | Patch
    | Trace


type alias Info =
    { title : Maybe String
    , description : Maybe String
    , termsOfService : Maybe String
    , contact : Maybe Contact
    , license : Maybe License
    , version : Maybe String
    }


type alias License =
    { name : Maybe String
    , url : Maybe String
    }


type Link
    = LinkRef Reference
    | LinkInline
        { operationRef : Maybe String
        , operationId : Maybe String
        , parameters : Dict String AnyOrExpression
        , requestBody : Maybe AnyOrExpression
        , description : Maybe String
        , server : Maybe Server
        }


type alias MediaType =
    { schema : Maybe Schema
    , example : String
    , examples : Dict String Example
    , encoding : Dict String Encoding
    }


type alias OAuthFlow =
    { authorizationUrl : Maybe String
    , tokenUrl : Maybe String
    , refreshUrl : Maybe String
    , scopes : Dict String String
    }


type alias OAuthFlows =
    { implicit : Maybe OAuthFlow
    , password : Maybe OAuthFlow
    , clientCredentials : Maybe OAuthFlow
    , authorizationCode : Maybe OAuthFlow
    }


type alias OpenApi =
    { info : Maybe Info
    , servers : List Server
    , security : Maybe SecurityRequirement
    , paths : Dict String PathItem
    , tags : List Tag
    , externalDocs : Maybe ExternalDocs
    , components : Maybe Components
    , ext : Dict String String
    }


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


type Parameter
    = ParameterRef Reference
    | ParameterInline
        { name : Maybe String
        , in_ : Maybe ParamIn

        -- Sane as Header from here on - merge the two?
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


type ParamIn
    = QueryParam
    | HeaderParam
    | PathParam
    | CookieParam


type alias PathItem =
    { ref : Maybe String
    , summary : Maybe String
    , description : Maybe String
    , operations : Dict HttpVerb Operation
    , servers : List Server
    , parameters : List Parameter
    }


type alias Reference =
    { ref : String
    }


type RequestBody
    = RequestBodyRef Reference
    | RequestBodyInline
        { description : Maybe String
        , content : Dict String MediaType
        , required : Maybe Bool
        }


type Response
    = ResponseRef Reference
    | ResponseInline
        { description : Maybe String
        , header : Dict String Header
        , content : Dict String MediaType
        , links : Dict String Link
        }


type Schema
    = SchemaRef Reference
    | SchemaInline
        { schema : JsonSchema.Schema
        , nullable : Maybe Bool
        , discriminator : Maybe Discriminator
        , readOnly : Maybe Bool
        , writeOnly : Maybe Bool
        , xml : Maybe Xml
        , externalDocs : Maybe ExternalDocs
        , example : Maybe Value
        , deprecated : Maybe Bool
        }


type alias SecurityRequirement =
    { schemes : Dict String (List String)
    }


type SecurityScheme
    = SecuritySchemeRef Reference
    | SecuritySchemeInline
        { type_ : Maybe String
        , description : Maybe String
        , name : Maybe String
        , in_ : Maybe SecurityTokenIn
        , scheme : Maybe String
        , bearerFormat : Maybe String
        , flows : Maybe OAuthFlows
        , openIdConnectUrl : Maybe String
        }


type SecurityTokenIn
    = QueryToken
    | HeaderToken
    | CookieToken


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


type Style
    = Matrix
    | Label
    | Form
    | Simple
    | SpaceDelimited
    | PipeDelimited
    | DeepObject


type alias Tag =
    { name : Maybe String
    , description : Maybe String
    , externalDocs : Maybe ExternalDocs
    }


type Version
    = Swager_2_0
    | OpenApi_3_0_0


type alias Xml =
    { name : Maybe String
    , namespace : Maybe String
    , prefix : Maybe String
    , attribute : Maybe Bool
    , wrapped : Maybe Bool
    }
