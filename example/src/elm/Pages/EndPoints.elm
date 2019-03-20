module Pages.EndPoints exposing (view)

import Css
import Dict
import Grid
import Html.Styled exposing (div, h1, h4, p, styled, text)
import Html.Styled.Attributes exposing (id)
import Html.Styled.Lazy exposing (lazy2)
import Index.Index as Index exposing (Index)
import Json.Schema.Definitions
import Maybe.Extra
import OpenApi.Model as OpenApi
import State exposing (Model, Msg(..), ViewState(..))
import Structure exposing (Template(..))
import Styles exposing (lg, md, sm, xl)
import TheSett.Buttons as Buttons


view : Template Msg Model
view =
    (\devices model ->
        div
            []
            [ case model.state of
                Loaded api ->
                    endpointsView model.searchTerm api

                _ ->
                    div [] []
            ]
    )
        |> lazy2
        |> Dynamic



-- View for the OpenAPI Spec


optionalTextField : String -> (a -> Maybe String) -> a -> Maybe (Html.Styled.Html Msg)
optionalTextField label exFn rec =
    let
        maybeVal =
            exFn rec
    in
    case maybeVal of
        Nothing ->
            Nothing

        Just val ->
            Just <|
                div []
                    [ text <| label ++ ": " ++ val
                    ]


optionalFlagField : String -> (a -> Maybe Bool) -> a -> Maybe (Html.Styled.Html Msg)
optionalFlagField label exFn rec =
    let
        maybeVal =
            exFn rec
    in
    case maybeVal of
        Nothing ->
            Nothing

        Just val ->
            Just <|
                div []
                    [ text <|
                        label
                            ++ ": "
                            ++ (if val then
                                    "true"

                                else
                                    "false"
                               )
                    ]


uncurry : (a -> b -> c) -> ( a, b ) -> c
uncurry fn =
    \( fst, snd ) -> fn fst snd


endpointsView : Maybe String -> OpenApi.OpenApi -> Html.Styled.Html Msg
endpointsView maybeSearch spec =
    div
        []
        [ pathsView maybeSearch spec
        ]


pathsView : Maybe String -> OpenApi.OpenApi -> Html.Styled.Html Msg
pathsView maybeSearch spec =
    div
        []
        (List.map (uncurry (pathView maybeSearch)) (Dict.toList spec.paths))


pathView : Maybe String -> String -> OpenApi.PathItem -> Html.Styled.Html Msg
pathView maybeSearch url path =
    let
        matches =
            case maybeSearch of
                Nothing ->
                    True

                Just term ->
                    Index.search path.index term
    in
    if matches then
        div []
            [ text url
            , styled div
                [ Css.paddingLeft <| Css.px 10 ]
                []
                (Maybe.Extra.values
                    [ optionalTextField "ref" .ref path
                    , optionalTextField "summary" .summary path
                    , optionalTextField "description" .description path
                    ]
                )
            , styled div
                [ Css.paddingLeft <| Css.px 10 ]
                []
                (List.map (uncurry operationView) path.operations)
            ]

    else
        div [] []


operationView : OpenApi.HttpVerb -> OpenApi.Operation -> Html.Styled.Html Msg
operationView verb op =
    div []
        [ text <| OpenApi.httpVerbToString verb
        , styled div
            [ Css.paddingLeft <| Css.px 10 ]
            []
            (Maybe.Extra.values
                [ optionalTextField "summary" .summary op
                , optionalTextField "description" .description op
                , optionalTextField "operationId" .operationId op
                , optionalFlagField "deprecated" .deprecated op
                ]
            )
        , styled div
            [ Css.paddingLeft <| Css.px 10 ]
            []
            [ List.intersperse ", " op.tags
                |> List.foldl (++) ""
                |> (++) "tags: "
                |> text
            ]
        ]
