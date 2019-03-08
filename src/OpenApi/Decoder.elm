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
import Json.Schema.Definitions as JsonSchema
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
        , stringToHttpVerb
        )



-- Decoders


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

todo: servers : List Server
todo: security : Maybe SecurityRequirement
todo: tags : List Tag
todo: externalDocs : Maybe ExternalDocs
todo: ext : Dict String String

-}
openApiDecoder : Decoder OpenApi
openApiDecoder =
    Decode.succeed
        (\version info paths components ->
            { defaultSpec
                | openapi = version
                , info = info
                , paths = paths
                , components = components
            }
        )
        |> andMap (field "openapi" versionDecoder)
        |> andMap (Decode.maybe (field "info" infoDecoder))
        |> andMap (field "paths" (Decode.dict pathItemDecoder))
        |> andMap (Decode.maybe (field "components" componentsDecoder))


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


componentsDecoder : Decoder Components
componentsDecoder =
    Decode.succeed
        (\schemas ->
            { schemas = schemas
            , parameters = Dict.empty
            , requestBodies = Dict.empty
            , responses = Dict.empty
            , examples = Dict.empty
            , headers = Dict.empty
            , links = Dict.empty
            , callbacks = Dict.empty
            , securitySchemes = Dict.empty
            }
        )
        |> andMap (field "schemas" (Decode.dict JsonSchema.decoder))


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


{-| Decodes URL paths.

This works by combinind together the 'pathItemPartialDecoder' and the 'httpVerbDecoder'.

-}
pathItemDecoder : Decoder PathItem
pathItemDecoder =
    Decode.map2
        (\pathItem operations ->
            { pathItem | operations = operations }
        )
        pathItemPartialDecoder
        httpVerbDecoder


{-| Decodes a PathItem, with the 'operations' field defaulted to empty.

This is because the operations are not supplied as a single field in the JSON,
but as fields named 'get', 'put', etc. Decoding the operations is done as a seperate
pass.

todo: servers : List Server
todo: parameters : List Parameter

-}
pathItemPartialDecoder : Decoder PathItem
pathItemPartialDecoder =
    Decode.succeed
        (\ref summary description ->
            { ref = ref
            , summary = summary
            , description = description
            , operations = []
            , servers = []
            , parameters = []
            }
        )
        |> andMap (Decode.maybe (field "ref" Decode.string))
        |> andMap (Decode.maybe (field "summary" Decode.string))
        |> andMap (Decode.maybe (field "description" Decode.string))


{-| Decodes just the HTTP operations from a PathItem.

The path operations are encoded in the JSON as fields named 'get', 'put', etc.
These fields are exatracted as a list of `( HttpVerb, Operation )` pairs.

-}
httpVerbDecoder : Decoder (List ( HttpVerb, Operation ))
httpVerbDecoder =
    let
        extractOperations : Dict String Operation -> List ( HttpVerb, Operation )
        extractOperations dict =
            Dict.foldl
                (\verb operation accum ->
                    case stringToHttpVerb verb of
                        Just httpVerb ->
                            ( httpVerb, operation ) :: accum

                        Nothing ->
                            accum
                )
                []
                dict
    in
    Decode.dict operationDecoder
        |> Decode.map extractOperations


{-| Decodes a description of an operation on an endpoint by an HTTP verb.

todo: externalDocs : Maybe ExternalDocs
todo: requestBody : Maybe RequestBody
todo: responses : Dict String Response
todo: callbacks : Dict String Callback
todo: security : Dict String (List String)

-}
operationDecoder : Decoder Operation
operationDecoder =
    Decode.succeed
        (\tags summary description operationId parameters deprecated ->
            { tags = tags
            , summary = summary
            , description = description
            , externalDocs = Nothing
            , operationId = operationId
            , parameters = parameters
            , requestBody = Nothing
            , responses = Dict.empty
            , callbacks = Dict.empty
            , deprecated = deprecated
            , security = Dict.empty
            , servers = []
            }
        )
        |> andMap (field "tags" (Decode.list Decode.string))
        |> andMap (Decode.maybe (field "summary" Decode.string))
        |> andMap (Decode.maybe (field "description" Decode.string))
        |> andMap (Decode.maybe (field "operationId" Decode.string))
        |> andMap (field "parameters" (Decode.list parameterDecoder))
        |> andMap (Decode.maybe (field "deprecated" Decode.bool))


parameterDecoder : Decoder Parameter
parameterDecoder =
    Decode.oneOf [ parameterRefDecoder, parameterInlineDecoder ]


parameterRefDecoder : Decoder Parameter
parameterRefDecoder =
    Decode.succeed
        (\ref ->
            ParameterRef { ref = "" }
        )
        |> andMap (field "ref" Decode.string)


{-| todo:
name : Maybe String
description : Maybe String
required : Maybe Bool
deprecated : Maybe Bool
allowEmptyValue : Maybe Bool
style : Maybe Style
explode : Maybe Bool
allowReserved : Maybe Bool
schema : Maybe Schema
example : Maybe String
examples : Dict String Example
content : Dict String MediaType
-}
parameterInlineDecoder : Decoder Parameter
parameterInlineDecoder =
    Decode.succeed <|
        ParameterInline
            { name = Nothing
            , in_ = Nothing
            , description = Nothing
            , required = Nothing
            , deprecated = Nothing
            , allowEmptyValue = Nothing
            , style = Nothing
            , explode = Nothing
            , allowReserved = Nothing
            , schema = Nothing
            , example = Nothing
            , examples = Dict.empty
            , content = Dict.empty
            }
