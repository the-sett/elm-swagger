module Pages.DataModel exposing (view)

import Css
import Dict
import Html.Styled exposing (div, h1, h2, h3, h4, li, ol, p, pre, styled, text, ul)
import Html.Styled.Attributes exposing (id)
import Html.Styled.Lazy exposing (lazy2)
import Json.Encode
import Json.Schema.Definitions
import Maybe.Extra
import OpenApi.Model as OpenApi
import State exposing (Model, Msg(..), ViewState(..))
import Structure exposing (Template(..))


view : Template Msg Model
view =
    (\devices model ->
        div
            []
            [ case model.state of
                Loaded api ->
                    dataModelView model.searchTerm api

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


dataModelView : Maybe String -> OpenApi.OpenApi -> Html.Styled.Html Msg
dataModelView maybeSearch spec =
    div
        []
        [ case spec.components of
            Just components ->
                componentsView maybeSearch components

            Nothing ->
                text "No schemas"
        ]


componentsView : Maybe String -> OpenApi.Components -> Html.Styled.Html Msg
componentsView maybeSearch components =
    div
        []
        (List.map (uncurry (schemaView maybeSearch)) (Dict.toList components.schemas))


schemaView : Maybe String -> String -> OpenApi.Schema -> Html.Styled.Html Msg
schemaView maybeSearch name schema =
    let
        matches =
            case maybeSearch of
                Nothing ->
                    True

                Just term ->
                    String.contains (String.toLower term) (String.toLower name)
    in
    if matches then
        case schema of
            OpenApi.SchemaRef _ ->
                div [] [ text "$ref" ]

            OpenApi.SchemaInline inlineSchema ->
                div []
                    [ text name
                    , styled div
                        [ Css.paddingLeft <| Css.px 10
                        , Css.fontSize <| Css.px 14
                        ]
                        []
                        [ pre []
                            [ Json.Schema.Definitions.encode inlineSchema.schema
                                |> Json.Encode.encode 4
                                |> text
                            ]
                        ]
                    ]

    else
        div [] []
