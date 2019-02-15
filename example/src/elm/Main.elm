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


type alias Model =
    { laf : Laf.Model
    , debugStyle : Bool
    , apiSpecUrl : String
    }


type Msg
    = LafMsg Laf.Msg
    | ToggleGrid
    | SetAPISpecUrl String


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { laf = Laf.init
      , debugStyle = False
      , apiSpecUrl = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case Debug.log "msg" action of
        LafMsg lafMsg ->
            Laf.update LafMsg lafMsg model.laf
                |> Tuple.mapFirst (\laf -> { model | laf = laf })

        ToggleGrid ->
            ( { model | debugStyle = not model.debugStyle }, Cmd.none )

        SetAPISpecUrl str ->
            ( { model | apiSpecUrl = str }, Cmd.none )



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
            , initialView model
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
            "Explore OpenAPI"
            [ form []
                [ Textfield.text
                    LafMsg
                    [ 1 ]
                    model.laf
                    [ Textfield.value model.apiSpecUrl ]
                    [ onInput SetAPISpecUrl
                    ]
                    [ text "URL" ]
                    devices
                ]
            ]
            [ Buttons.button [] [] [ text "Load" ] devices ]
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
