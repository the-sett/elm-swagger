module Pages.EndPoints exposing (view)

import Colors
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
import ViewUtils exposing (highlight, optionalFlagField, optionalTextField, uncurry)


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
        div
            []
            [ styled div
                [ Css.paddingLeft <| Css.px 10 ]
                []
                (List.map (uncurry (operationView devices maybeSearch url path)) path.operations)
            ]

    else
        div [] []


operationView : ResponsiveStyle -> Maybe String -> String -> OpenApi.PathItem -> OpenApi.HttpVerb -> OpenApi.Operation -> Html.Styled.Html Msg
operationView devices maybeSearch url path verb op =
    styled div
        [ Responsive.deviceStyles devices
            (\device ->
                [ Css.marginBottom <| Css.px (Responsive.rhythm 0.5 device)
                , Css.marginTop <| Css.px (Responsive.rhythm 0.5 device)
                , Css.padding <| Css.px (Responsive.rhythm 0.5 device)
                , Css.border3 (Css.px 1) Css.solid Colors.midGrey
                ]
            )
        , Css.borderRadius (Css.px 4)
        , Css.backgroundColor Colors.paperWhite
        ]
        []
        [ text <| OpenApi.httpVerbToString verb
        , text url
        , op.summary |> Maybe.withDefault "" |> highlight maybeSearch
        , styled div
            [ Css.paddingLeft <| Css.px 10 ]
            []
            (Maybe.Extra.values
                [ optionalTextField maybeSearch "description" .description op
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
