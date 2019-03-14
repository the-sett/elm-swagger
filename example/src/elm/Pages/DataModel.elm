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
                    dataModelView api

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


dataModelView : OpenApi.OpenApi -> Html.Styled.Html Msg
dataModelView spec =
    div
        []
        [ case spec.components of
            Just components ->
                componentsView components

            Nothing ->
                text "No schemas"
        ]


componentsView : OpenApi.Components -> Html.Styled.Html Msg
componentsView components =
    div
        []
        (List.map (uncurry schemaView) (Dict.toList components.schemas))


schemaView : String -> Json.Schema.Definitions.Schema -> Html.Styled.Html Msg
schemaView name schema =
    div []
        [ text name
        , styled div
            [ Css.paddingLeft <| Css.px 10
            , Css.fontSize <| Css.px 14
            ]
            []
            [ pre []
                [ Json.Schema.Definitions.encode schema
                    |> Json.Encode.encode 4
                    |> text
                ]
            ]
        ]
