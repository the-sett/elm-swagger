module Main exposing (init, update, view, Model, Msg)

{-| The content editor client top module.

@docs init, update, view, Model, Msg

-}

import Browser
import Css
import Css.Global
import Grid
import Html
import Html.Styled exposing (div, form, h4, img, label, span, styled, text, toUnstyled)
import Html.Styled.Attributes exposing (for, name, src)
import Html.Styled.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Decode.Generic as Json
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
                            ( { model | state = DecodeError err }, Cmd.none )

                        Ok spec ->
                            ( { model | state = Loaded spec }, Cmd.none )



-- View


paperWhite =
    Css.rgb 248 248 248


global : List Css.Global.Snippet
global =
    [ Css.Global.each
        [ Css.Global.html ]
        [ Css.height <| Css.pct 100
        , Responsive.deviceStyle devices
            (\device ->
                let
                    headerPx =
                        Responsive.rhythm 9.5 device
                in
                Css.property "background" <|
                    "linear-gradient(rgb(120, 116, 120) 0%, "
                        ++ String.fromFloat headerPx
                        ++ "px, rgb(225, 212, 214) 0px, rgb(208, 212, 214) 100%)"
            )
        ]
    ]


{-| Top level view function.
-}
view : Model -> Browser.Document Msg
view model =
    { title = "Swagger Example"
    , body = [ body model ]
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
    let
        decodeErrorToString error =
            "Malformed OpenAPI Spec JSON"
    in
    framing <|
        [ card "images/data_center-large.png"
            "Explore OpenApi"
            [ text <| decodeErrorToString err ]
            [ Buttons.button []
                [ onClick TryAgain ]
                [ text "Try Again" ]
                devices
            ]
            devices
        ]


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



-- Pretty Printing the OpenAPI Spec


loadedView : OpenApi.OpenApi -> Html.Styled.Html Msg
loadedView spec =
    styled div
        [ Css.property "background" "white" ]
        []
        [ text "loaded" ]
