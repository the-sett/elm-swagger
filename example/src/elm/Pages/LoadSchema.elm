module Pages.LoadSchema exposing (view)

import Colors
import Css
import Grid
import Html.Styled exposing (div, form, h1, h4, img, label, p, pre, span, styled, text, toUnstyled)
import Html.Styled.Attributes exposing (id)
import Html.Styled.Events exposing (onClick, onInput)
import Html.Styled.Lazy exposing (lazy2)
import Http
import Json.Decode as Decode
import Maybe.Extra
import Responsive
import State exposing (Model, Msg(..), ViewState(..))
import Structure exposing (Template(..))
import Styles exposing (lg, md, sm, xl)
import TheSett.Buttons as Buttons
import TheSett.Cards as Cards
import TheSett.Laf as Laf exposing (devices)
import TheSett.Textfield as Textfield


view : Template Msg Model
view =
    (\devices model ->
        div
            []
            [ case model.state of
                GetSpec ->
                    loadView model

                FetchError err ->
                    fetchErrorView err

                DecodeError err ->
                    decodeErrorView err

                _ ->
                    loadView model
            ]
    )
        |> lazy2
        |> Dynamic


loadView : Model -> Html.Styled.Html Msg
loadView model =
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
                , Css.backgroundColor Colors.paperWhite
                ]
            ]
        , md
            [ Styles.styles
                [ Css.maxWidth <| Css.px 820
                , Css.minWidth <| Css.px 800
                , Css.backgroundColor Colors.paperWhite
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
