module OpenApi.Decoder exposing (openApiDecoder)

{-| Decoders for Swagger Specs.

@docs decoder

-}

import Dict exposing (Dict)
import Json.Decode as Decode
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
import OpenApi.Model
    exposing
        ( AnyOrExpression(..)
        , Callback(..)
        , Components
        , Contact
        , Discriminator
        , Encoding
        , Example(..)
        , ExternalDocs
        , Header(..)
        , HttpVerb(..)
        , Info
        , License
        , Link(..)
        , MediaType
        , OAuthFlow
        , OAuthFlows
        , OpenApi
        , Operation
        , ParamIn(..)
        , Parameter(..)
        , PathItem
        , Reference
        , RequestBody(..)
        , Response(..)
        , Schema(..)
        , SecurityRequirement
        , SecurityScheme(..)
        , SecurityTokenIn(..)
        , Server
        , ServerVariable
        , Style(..)
        , Tag
        , Version(..)
        , Xml
        )


defaultSpec : OpenApi
defaultSpec =
    { openapi = OpenApi_3_0_0
    , info = Nothing
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
openApiDecoder : Decoder OpenApi
openApiDecoder =
    Decode.succeed
        (\version info ->
            { defaultSpec
                | openapi = version
                , info = info
            }
        )
        |> andMap (field "openapi" versionDecoder)
        |> andMap (Decode.maybe (field "info" infoDecoder))


versionDecoder : Decoder Version
versionDecoder =
    let
        toVersion str =
            case str of
                "3.0.0" ->
                    succeed OpenApi_3_0_0

                "3.0.1" ->
                    succeed OpenApi_3_0_1

                "3.0.2" ->
                    succeed OpenApi_3_0_2

                _ ->
                    Decode.fail ("unknown version: " ++ str)
    in
    Decode.string
        |> andThen toVersion


infoDecoder : Decoder Info
infoDecoder =
    Decode.succeed
        (\title description termsOfService contact license version ->
            { title = title
            , description = description
            , termsOfService = termsOfService
            , contact = contact
            , license = license
            , version = version
            }
        )
        |> andMap (Decode.maybe (field "title" Decode.string))
        |> andMap (Decode.maybe (field "description" Decode.string))
        |> andMap (Decode.maybe (field "termsOfService" Decode.string))
        |> andMap (Decode.maybe (field "contact" contactDecoder))
        |> andMap (Decode.maybe (field "license" licenseDecoder))
        |> andMap (Decode.maybe (field "version" Decode.string))


licenseDecoder : Decoder License
licenseDecoder =
    Decode.succeed
        (\name url ->
            { name = name
            , url = url
            }
        )
        |> andMap (Decode.maybe (field "name" Decode.string))
        |> andMap (Decode.maybe (field "url" Decode.string))


contactDecoder : Decoder Contact
contactDecoder =
    Decode.succeed
        (\name url email ->
            { name = name
            , url = url
            , email = email
            }
        )
        |> andMap (Decode.maybe (field "name" Decode.string))
        |> andMap (Decode.maybe (field "url" Decode.string))
        |> andMap (Decode.maybe (field "email" Decode.string))
