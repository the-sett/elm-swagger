module Pages.EndPoints exposing (view)

import Css
import Dict
import Grid
import Html.Styled exposing (div, h1, h4, p, span, styled, text)
import Html.Styled.Attributes exposing (id)
import Html.Styled.Lazy exposing (lazy2)
import Index.Index as Index exposing (Index)
import Json.Schema.Definitions
import List.Extra
import Maybe.Extra
import OpenApi.Model as OpenApi
import Regex
import Responsive exposing (ResponsiveStyle)
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
                    endpointsView devices model.searchTerm api

                _ ->
                    div [] []
            ]
    )
        |> lazy2
        |> Dynamic



-- View for the OpenAPI Spec


optionalTextField : Maybe String -> String -> (a -> Maybe String) -> a -> Maybe (Html.Styled.Html Msg)
optionalTextField maybeSearch label exFn rec =
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
                    [ highlight maybeSearch <| label ++ ": " ++ val
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


endpointsView : ResponsiveStyle -> Maybe String -> OpenApi.OpenApi -> Html.Styled.Html Msg
endpointsView devices maybeSearch spec =
    div
        []
        [ pathsView devices maybeSearch spec
        ]


pathsView : ResponsiveStyle -> Maybe String -> OpenApi.OpenApi -> Html.Styled.Html Msg
pathsView devices maybeSearch spec =
    div
        []
        (List.map (uncurry (pathView devices maybeSearch)) (Dict.toList spec.paths))


pathView : ResponsiveStyle -> Maybe String -> String -> OpenApi.PathItem -> Html.Styled.Html Msg
pathView devices maybeSearch url path =
    let
        matches =
            case maybeSearch of
                Nothing ->
                    True

                Just term ->
                    Index.search path.index term
    in
    if matches then
        styled div
            [ Responsive.deviceStyle devices
                (\device -> Css.marginBottom <| Css.px (Responsive.rhythm 1.0 device))
            ]
            []
            [ text url
            , styled div
                [ Css.paddingLeft <| Css.px 10
                ]
                []
                (Maybe.Extra.values
                    [ optionalTextField maybeSearch "ref" .ref path
                    , optionalTextField maybeSearch "summary" .summary path
                    , optionalTextField maybeSearch "description" .description path
                    ]
                )
            , styled div
                [ Css.paddingLeft <| Css.px 10 ]
                []
                (List.map (uncurry (operationView maybeSearch)) path.operations)
            ]

    else
        div [] []


operationView : Maybe String -> OpenApi.HttpVerb -> OpenApi.Operation -> Html.Styled.Html Msg
operationView maybeSearch verb op =
    div []
        [ text <| OpenApi.httpVerbToString verb
        , styled div
            [ Css.paddingLeft <| Css.px 10 ]
            []
            (Maybe.Extra.values
                [ optionalTextField maybeSearch "summary" .summary op
                , optionalTextField maybeSearch "description" .description op
                , optionalTextField maybeSearch "operationId" .operationId op
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


highlight : Maybe String -> String -> Html.Styled.Html msg
highlight maybeSearch val =
    case maybeSearch of
        Nothing ->
            text val

        Just search ->
            let
                attribute =
                    Css.backgroundColor <| Css.rgb 65 219 119

                regex =
                    toRegex search

                matches =
                    Regex.find regex val |> List.map (\match -> styled span [ attribute ] [] [ text match.match ])

                rest =
                    Regex.split regex val |> List.map text
            in
            span [] (List.Extra.interweave rest matches)


toRegex : String -> Regex.Regex
toRegex string =
    if string == "" then
        Regex.never

    else
        Regex.fromStringWith { caseInsensitive = True, multiline = False } string |> Maybe.withDefault Regex.never
