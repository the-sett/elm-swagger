module Layouts.Landing exposing (layout)

import Css
import Grid
import Html.Styled exposing (Html, a, button, div, input, li, nav, node, styled, text, ul)
import Html.Styled.Attributes exposing (attribute, checked, class, href, id, type_)
import Html.Styled.Events exposing (onClick)
import Responsive exposing (ResponsiveStyle)
import State exposing (Model, Msg(..), Page(..))
import Structure exposing (Layout, Template(..))
import Styles exposing (md, sm)
import Svg.Styled
import TheSett.Laf as Laf exposing (wrapper)
import TheSett.Logo as Logo


layout : Layout Msg Model
layout template =
    pageBody template


pageBody : Template Msg Model -> Template Msg Model
pageBody template =
    (\devices model ->
        div
            []
            [ debugToggle devices model
            , case template of
                Dynamic fn ->
                    fn devices model

                Static fn ->
                    Html.Styled.map never <| fn devices
            ]
    )
        |> Dynamic


debugToggle responsive model =
    styled div
        [ Css.position Css.fixed
        , Responsive.deviceStyles responsive <|
            \device ->
                [ Css.right (Responsive.rhythmPx 2 device)
                , Css.top (Responsive.rhythmPx 1 device)
                ]
        , if model.debug then
            Css.backgroundColor (Css.rgb 50 230 50) |> Css.important

          else
            Css.backgroundColor (Css.rgb 255 255 255)
        , Css.hover [ Css.backgroundColor (Css.rgb 50 210 50) ]
        , Css.padding2 (Css.px 5) (Css.px 10)
        , Css.margin (Css.px -5)
        , Css.boxShadow5 (Css.px 0) (Css.px 0) (Css.px 3) (Css.px 0) (Css.rgba 0 0 0 0.75)
        , Css.borderRadius (Css.px 4)
        , Css.property "user-select" "none"
        ]
        [ onClick <| Toggle (not model.debug) ]
        [ text "grid"
        ]
