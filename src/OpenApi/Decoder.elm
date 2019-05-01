module OpenApi.Decoder exposing (openApiDecoder)

{-| Decoders for Swagger Specs.

@docs decoder

-}

import Dict exposing (Dict)
import Index.Index as Index exposing (Index)
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
            let
                idx =
                    Dict.foldl
                        (\k v accum ->
                            Index.addString k
                                |> Index.addIndex v.index
                                |> Index.addIndex accum
                        )
                        Index.empty
                        paths
            in
            { defaultSpec
                | openapi = version
                , info = Maybe.map Tuple.first info
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


infoDecoder : Decoder ( Info, Index )
infoDecoder =
    Decode.succeed
        (\title description termsOfService contact license version ->
            let
                idx =
                    Index.addMaybeString title
                        |> Index.addIndex (Index.addMaybeString title)
                        |> Index.addIndex (Index.addMaybeString description)
                        |> Index.addIndex (Index.addMaybeString termsOfService)

                -- |> Index.addIndex (Index.addMaybeString contact)
                -- |> Index.addIndex (Index.addMaybeString license)
            in
            ( { title = title
              , description = description
              , termsOfService = termsOfService
              , contact = Maybe.map Tuple.first contact
              , license = Maybe.map Tuple.first license
              , version = version
              }
            , idx
            )
        )
        |> andMap (Decode.maybe (field "title" Decode.string))
        |> andMap (Decode.maybe (field "description" Decode.string))
        |> andMap (Decode.maybe (field "termsOfService" Decode.string))
        |> andMap (Decode.maybe (field "contact" contactDecoder))
        |> andMap (Decode.maybe (field "license" licenseDecoder))
        |> andMap (Decode.maybe (field "version" Decode.string))


licenseDecoder : Decoder ( License, Index )
licenseDecoder =
    Decode.succeed
        (\name url ->
            let
                idx =
                    Index.addMaybeString name
                        |> Index.addIndex (Index.addMaybeString url)
            in
            ( { name = name
              , url = url
              }
            , idx
            )
        )
        |> andMap (Decode.maybe (field "name" Decode.string))
        |> andMap (Decode.maybe (field "url" Decode.string))


componentsDecoder : Decoder Components
componentsDecoder =
    Decode.succeed
        (\schemas parameters requestBodies responses ->
            let
                idx =
                    Dict.foldl
                        (\key _ accum ->
                            Index.addString key
                                |> Index.addIndex accum
                        )
                        Index.empty
                        schemas
            in
            { schemas = schemas
            , parameters = Dict.empty
            , requestBodies = Dict.empty
            , responses = Dict.empty
            , examples = Dict.empty
            , headers = Dict.empty
            , links = Dict.empty
            , callbacks = Dict.empty
            , securitySchemes = Dict.empty
            , index = idx
            }
        )
        |> andMap (field "schemas" (Decode.dict schemaDecoder))
        |> andMap (field "parameters" (Decode.dict parameterDecoder))
        |> andMap (field "requestBodies" (Decode.dict requestBodyDecoder))
        |> andMap (field "responses" (Decode.dict responseDecoder))


contactDecoder : Decoder ( Contact, Index )
contactDecoder =
    Decode.succeed
        (\name url email ->
            let
                idx =
                    Index.addMaybeString name
                        |> Index.addIndex (Index.addMaybeString url)
                        |> Index.addIndex (Index.addMaybeString email)
            in
            ( { name = name
              , url = url
              , email = email
              }
            , idx
            )
        )
        |> andMap (Decode.maybe (field "name" Decode.string))
        |> andMap (Decode.maybe (field "url" Decode.string))
        |> andMap (Decode.maybe (field "email" Decode.string))


{-| Decodes URL paths.

This works by combining together the 'pathItemPartialDecoder' and the 'httpVerbDecoder'.

-}
pathItemDecoder : Decoder PathItem
pathItemDecoder =
    Decode.map2
        (\( pathItem, pathItemIndex ) indexedOperations ->
            let
                operationIdx =
                    List.foldl
                        (\( _, _, idx ) accum ->
                            Index.addIndex idx accum
                        )
                        Index.empty
                        indexedOperations

                operations =
                    List.map (\( verb, op, _ ) -> ( verb, op )) indexedOperations
            in
            { pathItem
                | operations = operations
                , index =
                    Index.addIndex pathItemIndex operationIdx
                        |> Index.prepare
            }
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
pathItemPartialDecoder : Decoder ( PathItem, Index )
pathItemPartialDecoder =
    Decode.succeed
        (\ref summary description ->
            let
                idx =
                    Index.addMaybeString ref
                        |> Index.addIndex (Index.addMaybeString summary)
                        |> Index.addIndex (Index.addMaybeString description)
            in
            ( { ref = ref
              , summary = summary
              , description = description
              , operations = []
              , servers = []
              , parameters = []
              , index = Index.empty
              }
            , idx
            )
        )
        |> andMap (Decode.maybe (field "$ref" Decode.string))
        |> andMap (Decode.maybe (field "summary" Decode.string))
        |> andMap (Decode.maybe (field "description" Decode.string))


{-| Decodes just the HTTP operations from a PathItem.

The path operations are encoded in the JSON as fields named 'get', 'put', etc.
These fields are exatracted as a list of `( HttpVerb, Operation )` pairs.

-}
httpVerbDecoder : Decoder (List ( HttpVerb, Operation, Index ))
httpVerbDecoder =
    let
        extractOperations : Dict String ( Operation, Index ) -> List ( HttpVerb, Operation, Index )
        extractOperations dict =
            Dict.foldl
                (\verb ( operation, index ) accum ->
                    case stringToHttpVerb verb of
                        Just httpVerb ->
                            ( httpVerb, operation, index ) :: accum

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
operationDecoder : Decoder ( Operation, Index )
operationDecoder =
    Decode.succeed
        (\tags summary description operationId paramsWithIdxBuilders deprecated ->
            let
                ( parameters, paramIdxs ) =
                    List.unzip paramsWithIdxBuilders

                paramIdx =
                    List.foldl
                        (\index accum ->
                            Index.addIndex index accum
                        )
                        Index.empty
                        paramIdxs

                idx =
                    Index.addStrings tags
                        |> Index.addIndex (Index.addMaybeString summary)
                        |> Index.addIndex (Index.addMaybeString description)
                        |> Index.addIndex (Index.addMaybeString operationId)
                        |> Index.addIndex paramIdx
            in
            ( { tags = tags
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
            , idx
            )
        )
        |> andMap (maybeListDecoder (Decode.maybe (field "tags" (Decode.list Decode.string))))
        |> andMap (Decode.maybe (field "summary" Decode.string))
        |> andMap (Decode.maybe (field "description" Decode.string))
        |> andMap (Decode.maybe (field "operationId" Decode.string))
        |> andMap (maybeListDecoder (Decode.maybe (field "parameters" (Decode.list parameterDecoder))))
        |> andMap (Decode.maybe (field "deprecated" Decode.bool))


maybeListDecoder : Decoder (Maybe (List a)) -> Decoder (List a)
maybeListDecoder =
    Decode.map
        (\maybeList ->
            case maybeList of
                Nothing ->
                    []

                Just list ->
                    list
        )


parameterDecoder : Decoder ( Parameter, Index )
parameterDecoder =
    Decode.oneOf [ parameterRefDecoder, parameterInlineDecoder ]


parameterRefDecoder : Decoder ( Parameter, Index )
parameterRefDecoder =
    Decode.succeed
        (\ref ->
            ( ParameterRef
                { ref = ref
                }
            , Index.addString ref
            )
        )
        |> andMap (field "$ref" Decode.string)


{-| todo:
required : Maybe Bool
deprecated : Maybe Bool
allowEmptyValue : Maybe Bool
style : Maybe Style
explode : Maybe Bool
allowReserved : Maybe Bool
schema : Maybe Schema
examples : Dict String Example
content : Dict String MediaType
-}
parameterInlineDecoder : Decoder ( Parameter, Index )
parameterInlineDecoder =
    Decode.succeed
        (\name description example ->
            let
                idx =
                    Index.addMaybeString name
                        |> Index.addIndex (Index.addMaybeString description)
                        |> Index.addIndex (Index.addMaybeString example)
            in
            ( ParameterInline
                { name = name
                , in_ = Nothing
                , description = description
                , required = Nothing
                , deprecated = Nothing
                , allowEmptyValue = Nothing
                , style = Nothing
                , explode = Nothing
                , allowReserved = Nothing
                , schema = Nothing
                , example = example
                , examples = Dict.empty
                , content = Dict.empty
                }
            , idx
            )
        )
        |> andMap (Decode.maybe (field "name" Decode.string))
        |> andMap (Decode.maybe (field "description" Decode.string))
        |> andMap (Decode.maybe (field "example" Decode.string))


requestBodyDecoder : Decoder ( RequestBody, Index )
requestBodyDecoder =
    Decode.oneOf [ requestBodyRefDecoder, requestBodyInlineDecoder ]


requestBodyRefDecoder : Decoder ( RequestBody, Index )
requestBodyRefDecoder =
    Decode.succeed
        (\ref ->
            ( RequestBodyRef
                { ref = ref
                }
            , Index.addString ref
            )
        )
        |> andMap (field "$ref" Decode.string)


requestBodyInlineDecoder : Decoder ( RequestBody, Index )
requestBodyInlineDecoder =
    Decode.succeed
        (\description ->
            ( RequestBodyInline
                { description = description
                , content = Dict.empty
                , required = Nothing
                }
            , Index.empty
            )
        )
        |> andMap (Decode.maybe (field "description" Decode.string))


responseDecoder : Decoder ( Response, Index )
responseDecoder =
    Decode.oneOf [ responseRefDecoder, responseInlineDecoder ]


responseRefDecoder : Decoder ( Response, Index )
responseRefDecoder =
    Decode.succeed
        (\ref ->
            ( ResponseRef
                { ref = ref
                }
            , Index.addString ref
            )
        )
        |> andMap (field "$ref" Decode.string)


responseInlineDecoder : Decoder ( Response, Index )
responseInlineDecoder =
    Decode.succeed
        (\description ->
            ( ResponseInline
                { description = description
                , header = Dict.empty
                , content = Dict.empty
                , links = Dict.empty
                }
            , Index.empty
            )
        )
        |> andMap (Decode.maybe (field "description" Decode.string))


schemaDecoder : Decoder Schema
schemaDecoder =
    Decode.oneOf [ schemaRefDecoder, schemaInlineDecoder ]


schemaRefDecoder : Decoder Schema
schemaRefDecoder =
    Decode.map SchemaRef referenceDecoder


schemaInlineDecoder : Decoder Schema
schemaInlineDecoder =
    Decode.succeed
        (\schema ->
            SchemaInline
                { schema = schema
                , nullable = Nothing
                , discriminator = Nothing
                , readOnly = Nothing
                , writeOnly = Nothing
                , xml = Nothing
                , externalDocs = Nothing
                , example = Nothing
                , deprecated = Nothing
                }
         --, index = Index.empty
        )
        |> andMap JsonSchema.decoder


referenceDecoder : Decoder Reference
referenceDecoder =
    Decode.succeed
        (\ref -> { ref = ref })
        |> andMap (field "$ref" Decode.string)
