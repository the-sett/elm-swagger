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
        (\version info paths ->
            { defaultSpec
                | openapi = version
                , info = info
                , paths = paths
            }
        )
        |> andMap (field "openapi" versionDecoder)
        |> andMap (Decode.maybe (field "info" infoDecoder))
        |> andMap (field "paths" (Decode.dict pathItemDecoder))


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


httpVerbToString : HttpVerb -> String
httpVerbToString verb =
    case verb of
        Get ->
            "get"

        Put ->
            "put"

        Post ->
            "post"

        Delete ->
            "delete"

        Options ->
            "options"

        Head ->
            "head"

        Patch ->
            "patch"

        Trace ->
            "trace"


stringToHttpVerb : String -> Maybe HttpVerb
stringToHttpVerb str =
    case String.toLower str of
        "get" ->
            Just Get

        "put" ->
            Just Put

        "post" ->
            Just Post

        "delete" ->
            Just Delete

        "options" ->
            Just Options

        "head" ->
            Just Head

        "patch" ->
            Just Patch

        "trace" ->
            Just Trace

        _ ->
            Nothing


pathItemDecoder : Decoder PathItem
pathItemDecoder =
    Decode.succeed
        (\ref summary description gets ->
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
        |> andMap (Decode.maybe (field "get" operationDecoder))



-- httpVerbDecoder : Decoder HttpVerb
-- httpVerbDecoder =
--     let
--         httpVerbFilter k _ =
--             List.member (String.toLower k) [ "get", "put", "post", "delete", "options", "head", "patch", "trace" ]
--     in
--     Decode.dict operationDecoder
--         |> Decode.map (Dict.filter httpVerbFilter)
--         |> Decode.map (Dict.map (\k v -> stringToHttpVerb k <| v))
-- { ref : Maybe String
-- , summary : Maybe String
-- , description : Maybe String
-- , operations : Dict HttpVerb Operation
-- , servers : List Server
-- , parameters : List Parameter
-- }


operationDecoder : Decoder Operation
operationDecoder =
    Decode.succeed
        { tags = []
        , summary = Nothing
        , description = Nothing
        , externalDocs = Nothing
        , operationId = Nothing
        , parameters = []
        , requestBody = Nothing
        , responses = Dict.empty
        , callbacks = Dict.empty
        , deprecated = False
        , security = Dict.empty
        , servers = []
        }



-- type alias Operation =
--     { tags : List String
--     , summary : Maybe String
--     , description : Maybe String
--     , externalDocs : Maybe ExternalDocs
--     , operationId : Maybe String
--     , parameters : List Parameter
--     , requestBody : Maybe RequestBody
--     , responses : Dict String Response
--     , callbacks : Dict String Callback
--     , deprecated : Bool
--     , security : Dict String (List String)
--     , servers : List Server
--     }
