module Main exposing (main)

import Body
import Browser
import Browser.Dom exposing (getViewportOf, setViewportOf)
import Css.Global
import Demo.Buttons
import Demo.Cards
import Demo.Grid
import Demo.Typography
import Html.Styled exposing (div, input, text, toUnstyled)
import Html.Styled.Attributes exposing (checked, type_)
import Html.Styled.Events exposing (onCheck)
import Layout
import State exposing (Model, Msg(..), Page(..))
import Structure exposing (Template(..))
import Task
import TheSett.Debug
import TheSett.Laf as Laf
import TheSett.Logo


main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = \model -> { title = "The Sett LAF", body = [ view model ] }
        }


init () =
    ( { debug = False, page = Typography }, Cmd.none )


subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" msg of
        Toggle state ->
            ( { model | debug = state }, Cmd.none )

        SwitchTo page ->
            ( { model | page = page }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


jumpToId : String -> Cmd Msg
jumpToId id =
    Browser.Dom.getElement id
        |> Task.andThen (\info -> Browser.Dom.setViewport 0 (Debug.log "viewport" info).element.y)
        |> Task.attempt (\_ -> NoOp)


view model =
    styledView model
        |> toUnstyled


styledView : Model -> Html.Styled.Html Msg
styledView model =
    let
        innerView =
            [ Laf.responsiveMeta
            , Laf.fonts
            , Laf.style Laf.devices
            , case
                Layout.layout <| Body.view (viewForPage model.page)
              of
                Dynamic fn ->
                    fn Laf.devices model

                Static fn ->
                    Html.Styled.map never <| fn Laf.devices
            ]

        debugStyle =
            Css.Global.global <|
                TheSett.Debug.global Laf.devices
    in
    case model.debug of
        True ->
            div [] (debugStyle :: innerView)

        False ->
            div [] innerView


viewForPage : Page -> Template Msg Model
viewForPage page =
    case page of
        Typography ->
            Demo.Typography.view

        Buttons ->
            Demo.Buttons.view

        Grid ->
            Demo.Grid.view

        Cards ->
            Demo.Cards.view
