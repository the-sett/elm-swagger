module Pages.DataModel exposing (view)

import Colors
import Css
import Dict
import Html.Styled exposing (div, h1, h2, h3, h4, li, ol, p, pre, styled, text, ul)
import Html.Styled.Attributes exposing (id)
import Html.Styled.Lazy exposing (lazy2)
import Json.Encode
import Json.Schema.Definitions
import Maybe.Extra
import OpenApi.Model as OpenApi
import Responsive exposing (ResponsiveStyle)
import State exposing (Model, Msg(..), ViewState(..))
import Structure exposing (Template(..))
import ViewUtils exposing (highlight, optionalFlagField, optionalTextField, uncurry)


view : Template Msg Model
view =
    (\devices model ->
        div
            []
            [ case model.state of
                Loaded api ->
                    dataModelView devices model.searchTerm api

                _ ->
                    div [] []
            ]
    )
        |> lazy2
        |> Dynamic



-- View for the OpenAPI Spec


dataModelView : ResponsiveStyle -> Maybe String -> OpenApi.OpenApi -> Html.Styled.Html Msg
dataModelView devices maybeSearch spec =
    div
        []
        [ case spec.components of
            Just components ->
                componentsView devices maybeSearch components

            Nothing ->
                text "No schemas"
        ]


componentsView : ResponsiveStyle -> Maybe String -> OpenApi.Components -> Html.Styled.Html Msg
componentsView devices maybeSearch components =
    div
        []
        (List.map (uncurry (schemaView devices maybeSearch)) (Dict.toList components.schemas))


schemaView : ResponsiveStyle -> Maybe String -> String -> OpenApi.Schema -> Html.Styled.Html Msg
schemaView devices maybeSearch name schema =
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
                    , Css.overflow Css.auto
                    ]
                    []
                    [ highlight maybeSearch name
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
