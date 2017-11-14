module Swagger exposing (Swagger)

{-| Provides a DSL for constructing Swagger Specs.

@docs Swagger

-}

import Dict exposing (Dict)
import Json.Encode as Encode
import Swagger.Model exposing (..)


{-| The type of Swagger Specs.
-}
type alias Swagger =
    Swagger.Model.Spec
