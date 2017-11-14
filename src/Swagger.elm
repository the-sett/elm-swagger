module Swagger exposing (Spec, swagger)

{-| Provides a DSL for constructing Swagger Specs.

@docs Spec, swagger

-}

import Dict exposing (Dict)
import Json.Encode as Encode
import Swagger.Model exposing (Spec(..))


{-| The type of Swagger Specs.
-}
type alias Spec =
    Swagger.Model.Spec


{-| A dummay swagger spec.
-}
swagger : Spec
swagger =
    Swagger.Model.Swagger
