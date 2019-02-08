module Swagger exposing (Spec, swagger)

{-| Provides a DSL for constructing Swagger Specs.

@docs Spec, swagger

-}

import Dict exposing (Dict)
import Json.Encode as Encode
import JsonSchema exposing (Schema)
import Swagger.Model exposing (..)


{-| The type of Swagger Specs.
-}
type alias Spec =
    Swagger.Model.OpenApi


{-| A dummay swagger spec.
-}
swagger : Spec
swagger =
    defaultSpec


defaultSpec : Spec
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



-- defaultTag : Tag
-- defaultTag =
--     { name = Nothing
--     }
--
--
-- defaultInfo : Info
-- defaultInfo =
--     {}
--
--
-- defaultPath : PathItem
-- defaultPath =
--     { tags = []
--     , summary = Nothing
--     , description = Nothing
--     , operationId = Nothing
--     , consumes = []
--     , produces = []
--     , parameters = []
--     , responses = Dict.empty
--     }
--
--
-- defaultParameter : Parameter
-- defaultParameter =
--     { in_ = Nothing
--     , name = Nothing
--     , description = Nothing
--     , required = Nothing
--     , type_ = Nothing
--     , schema = Nothing
--     }
--
--
-- defaultResponse : Response
-- defaultResponse =
--     { description = Nothing
--     , type_ = Nothing
--     , schema = Nothing
--     }


type alias SpecProperty =
    Spec -> Spec


type alias InfoProperty =
    Info -> Info


type alias PathProperty =
    PathItem -> PathItem


type alias ParameterProperty =
    Parameter -> Parameter


type alias ResponseProperty =
    Response -> Response
