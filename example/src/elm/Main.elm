module Main exposing (init, subscriptions, update, view, Model, Msg)

{-| The content editor client top module.

@docs init, subscriptions, update, view, Model, Msg

-}

import Browser
import Css
import Css.Global
import Dict
import Grid
import Html
import Html.Lazy
import Html.Styled exposing (div, form, h4, img, label, pre, span, styled, text, toUnstyled)
import Html.Styled.Attributes exposing (for, name, src)
import Html.Styled.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Decode.Generic as Json
import Json.Encode
import Json.Schema.Builder
import Json.Schema.Definitions
import Maybe.Extra
import OpenApi.Decoder
import OpenApi.Model as OpenApi
import Process
import Responsive
import Styles exposing (lg, md, sm, xl)
import Task
import TheSett.Buttons as Buttons
import TheSett.Cards as Cards
import TheSett.Debug
import TheSett.Laf as Laf exposing (devices, fonts, responsiveMeta, wrapper)
import TheSett.Textfield as Textfield
import Update2
import Update3
import Url exposing (Url)


type alias Model =
    { laf : Laf.Model
    , debugStyle : Bool
    , apiSpecPath : String
    , apiSpecUrl : Maybe Url
    , state : ViewState
    }


type ViewState
    = GetSpec
    | FetchError Http.Error
    | DecodeError Decode.Error
    | Loaded OpenApi.OpenApi


type Msg
    = LafMsg Laf.Msg
    | ToggleGrid
    | UpdateSpecUrl String
    | LoadSpec
    | TryAgain
    | FetchedApiSpec (Result Http.Error String)


debugMsg msg =
    case msg of
        LafMsg _ ->
            "LafMsg"

        ToggleGrid ->
            "ToggleGrid"

        UpdateSpecUrl _ ->
            "UpdateSpecUrl"

        LoadSpec ->
            "LoadSpec"

        TryAgain ->
            "TryAgain"

        FetchedApiSpec _ ->
            "FetchedApiSpec"


testSpec =
    "http://localhost:9071/example-specs/open-banking/payment-initiation-openapi.json"


initialModel =
    { laf = Laf.init
    , debugStyle = False
    , apiSpecPath = testSpec
    , apiSpecUrl = Url.fromString testSpec
    , state = GetSpec
    }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , Cmd.none
    )


subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    let
        _ =
            Debug.log "msg" (debugMsg action)
    in
    case action of
        LafMsg lafMsg ->
            Laf.update LafMsg lafMsg model.laf
                |> Tuple.mapFirst (\laf -> { model | laf = laf })

        ToggleGrid ->
            ( { model | debugStyle = not model.debugStyle }, Cmd.none )

        UpdateSpecUrl str ->
            ( { model | apiSpecPath = str, apiSpecUrl = Url.fromString str }, Cmd.none )

        LoadSpec ->
            ( model, getApiSpec model.apiSpecPath )

        TryAgain ->
            ( initialModel, Cmd.none )

        FetchedApiSpec result ->
            case result of
                Err err ->
                    ( { model | state = FetchError err }, Cmd.none )

                Ok val ->
                    case Decode.decodeString OpenApi.Decoder.openApiDecoder val of
                        Err err ->
                            let
                                _ =
                                    Debug.log "decode error" <| Decode.errorToString err
                            in
                            ( { model | state = DecodeError err }, Cmd.none )

                        Ok spec ->
                            ( { model | state = Loaded spec }, Cmd.none )



-- View


paperWhite =
    Css.rgb 248 248 248


softGrey =
    Css.rgb 225 212 214


global : List Css.Global.Snippet
global =
    [ Css.Global.each
        [ Css.Global.html ]
        [ Css.backgroundColor softGrey ]
    ]


{-| Top level view function.
-}
view : Model -> Browser.Document Msg
view model =
    { title = "Swagger Example"
    , body = [ Html.Lazy.lazy body model ]
    }


body : Model -> Html.Html Msg
body model =
    styledBody model
        |> toUnstyled


styledBody : Model -> Html.Styled.Html Msg
styledBody model =
    let
        innerView =
            [ responsiveMeta
            , fonts
            , Laf.style devices
            , Css.Global.global global
            , case model.state of
                GetSpec ->
                    initialView model

                FetchError err ->
                    fetchErrorView err

                DecodeError err ->
                    decodeErrorView err

                Loaded spec ->
                    loadedView spec
            ]

        debugStyle =
            Css.Global.global <|
                TheSett.Debug.global Laf.devices
    in
    case model.debugStyle of
        True ->
            div [] (debugStyle :: innerView)

        False ->
            div [] innerView


initialView : Model -> Html.Styled.Html Msg
initialView model =
    framing <|
        [ card "images/data_center-large.png"
            "Explore OpenApi"
            [ form []
                [ Textfield.text
                    LafMsg
                    [ 1 ]
                    model.laf
                    [ Textfield.value model.apiSpecPath ]
                    [ onInput UpdateSpecUrl
                    ]
                    [ text "URL" ]
                    devices
                ]
            ]
            [ Buttons.button []
                [ onClick LoadSpec
                , Html.Styled.Attributes.disabled <| Maybe.Extra.isNothing model.apiSpecUrl
                ]
                [ text "Load" ]
                devices
            ]
            devices
        ]


fetchErrorView : Http.Error -> Html.Styled.Html Msg
fetchErrorView err =
    let
        httpErrorToString error =
            case error of
                Http.BadUrl url ->
                    "Bad URL: " ++ url

                Http.Timeout ->
                    "Timed Out"

                Http.NetworkError ->
                    "Network Error"

                Http.BadStatus status ->
                    "Bad Status: " ++ String.fromInt status

                Http.BadBody desc ->
                    "Bad response: " ++ desc
    in
    framing <|
        [ card "images/data_center-large.png"
            "Explore OpenApi"
            [ text <| httpErrorToString err ]
            [ Buttons.button []
                [ onClick TryAgain ]
                [ text "Try Again" ]
                devices
            ]
            devices
        ]


decodeErrorView : Decode.Error -> Html.Styled.Html Msg
decodeErrorView err =
    styled div
        [ Css.backgroundColor <| Css.rgb 255 255 255 ]
        []
        [ text <| Decode.errorToString err ]


framing : List (Html.Styled.Html Msg) -> Html.Styled.Html Msg
framing innerHtml =
    styled div
        [ Responsive.deviceStyle devices
            (\device -> Css.marginTop <| Responsive.rhythmPx 3 device)
        ]
        []
        [ Grid.grid
            [ sm [ Grid.columns 12 ] ]
            []
            [ Grid.row
                [ sm [ Grid.center ] ]
                []
                [ Grid.col
                    []
                    []
                    innerHtml
                ]
            ]
            devices
        ]


card :
    String
    -> String
    -> List (Html.Styled.Html Msg)
    -> List (Html.Styled.Html Msg)
    -> Responsive.ResponsiveStyle
    -> Html.Styled.Html Msg
card imageUrl title cardBody controls devices =
    Cards.card
        [ sm
            [ Styles.styles
                [ Css.maxWidth <| Css.vw 100
                , Css.minWidth <| Css.px 310
                , Css.backgroundColor <| paperWhite
                ]
            ]
        , md
            [ Styles.styles
                [ Css.maxWidth <| Css.px 820
                , Css.minWidth <| Css.px 800
                , Css.backgroundColor <| paperWhite
                ]
            ]
        ]
        []
        [ Cards.image
            [ Styles.height 6
            , sm [ Cards.src imageUrl ]
            ]
            []
            [ styled div
                [ Css.position Css.relative
                , Css.height <| Css.pct 100
                ]
                []
                []
            ]
        , Cards.title title
        , Cards.body cardBody
        , Cards.controls controls
        ]
        devices



-- HTTP Interaction


getApiSpec : String -> Cmd Msg
getApiSpec url =
    Http.get
        { url = url
        , expect = Http.expectString FetchedApiSpec
        }



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


loadedView : OpenApi.OpenApi -> Html.Styled.Html Msg
loadedView spec =
    dataModelView spec


endpointsView : OpenApi.OpenApi -> Html.Styled.Html Msg
endpointsView spec =
    styled div
        [ Css.padding <| Css.px 10
        , Css.backgroundColor <| Css.rgb 255 255 255
        ]
        []
        [ h4 [] [ text "Endpoints" ]
        , pathsView spec
        ]


pathsView : OpenApi.OpenApi -> Html.Styled.Html Msg
pathsView spec =
    div
        []
        (List.map (uncurry pathView) (Dict.toList spec.paths))


pathView : String -> OpenApi.PathItem -> Html.Styled.Html Msg
pathView url path =
    div []
        [ text url
        , styled div
            [ Css.margin <| Css.px 10 ]
            []
            (Maybe.Extra.values
                [ optionalTextField "ref" .ref path
                , optionalTextField "summary" .summary path
                , optionalTextField "description" .description path
                ]
            )
        , styled div
            [ Css.margin <| Css.px 10 ]
            []
            (List.map (uncurry operationView) path.operations)
        ]


operationView : OpenApi.HttpVerb -> OpenApi.Operation -> Html.Styled.Html Msg
operationView verb op =
    div []
        [ text <| OpenApi.httpVerbToString verb
        , styled div
            [ Css.margin <| Css.px 10 ]
            []
            (Maybe.Extra.values
                [ optionalTextField "summary" .summary op
                , optionalTextField "description" .description op
                , optionalTextField "operationId" .operationId op
                , optionalFlagField "deprecated" .deprecated op
                ]
            )
        , styled div
            [ Css.margin <| Css.px 10 ]
            []
            [ List.intersperse ", " op.tags
                |> List.foldl (++) ""
                |> (++) "tags: "
                |> text
            ]
        ]


dataModelView : OpenApi.OpenApi -> Html.Styled.Html Msg
dataModelView spec =
    styled div
        [ Css.padding <| Css.px 10
        , Css.backgroundColor <| Css.rgb 255 255 255
        ]
        []
        [ h4 [] [ text "Data Model" ]
        , case spec.components of
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
            [ Css.padding <| Css.px 10
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
