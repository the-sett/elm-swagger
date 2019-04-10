module Main exposing (Model, Msg, init, subscriptions, update, view)

import Body
import Browser
import Browser.Dom exposing (getViewportOf, setViewportOf)
import Colors
import Css
import Css.Global
import Devices
import Html.Styled exposing (div, input, text, toUnstyled)
import Html.Styled.Attributes exposing (checked, type_)
import Html.Styled.Events exposing (onCheck)
import Http
import Index.Index as Index exposing (Index)
import Json.Decode as Decode
import Layouts.Explore
import Layouts.Landing
import OpenApi.Decoder
import Pages.DataModel
import Pages.EndPoints
import Pages.LoadSchema
import State exposing (Model, Msg(..), Page(..), ViewState(..))
import Structure exposing (Layout, Template(..))
import Task
import Task.Extra
import TheSett.Debug
import TheSett.Laf as Laf
import TheSett.Logo
import Trie exposing (Trie)
import Url exposing (Url)


type alias Model =
    State.Model


type alias Msg =
    State.Msg


testSpec =
    "http://localhost:9071/example-specs/open-banking/payment-initiation-openapi.json"


initialModel =
    { laf = Laf.init
    , debug = False
    , page = LoadSchema
    , apiSpecPath = testSpec
    , apiSpecUrl = Url.fromString testSpec
    , state = GetSpec
    , searchTerm = Nothing
    }


init () =
    ( initialModel, Cmd.none )


subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" msg of
        LafMsg lafMsg ->
            Laf.update LafMsg lafMsg model.laf
                |> Tuple.mapFirst (\laf -> { model | laf = laf })

        Toggle state ->
            ( { model | debug = state }, Cmd.none )

        SwitchTo page ->
            ( { model | page = page }, Cmd.none )

        UpdateSpecUrl str ->
            ( { model | apiSpecPath = str, apiSpecUrl = Url.fromString str }, Cmd.none )

        UpdateSearchTerm str ->
            let
                term =
                    if str == "" then
                        Nothing

                    else
                        Just str
            in
            ( { model | searchTerm = term }
            , Cmd.none
            )

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
                            ( { model | state = Loaded spec }
                            , Task.Extra.message <| SwitchTo EndPoints
                            )

        NoOp ->
            ( model, Cmd.none )


jumpToId : String -> Cmd Msg
jumpToId id =
    Browser.Dom.getElement id
        |> Task.andThen (\info -> Browser.Dom.setViewport 0 (Debug.log "viewport" info).element.y)
        |> Task.attempt (\_ -> NoOp)



-- HTTP Interaction


getApiSpec : String -> Cmd Msg
getApiSpec url =
    Http.get
        { url = url
        , expect = Http.expectString FetchedApiSpec
        }



-- View


deviceConfig =
    Devices.devices


global : List Css.Global.Snippet
global =
    [ Css.Global.each
        [ Css.Global.html ]
        [ Css.backgroundColor Colors.softGrey ]
    ]


view model =
    { title = "OpenAPI Viewer", body = [ body model ] }


body model =
    styledView model
        |> toUnstyled


styledView : Model -> Html.Styled.Html Msg
styledView model =
    let
        pageView =
            let
                ( layout, template ) =
                    viewForPage model.page
            in
            case
                layout <| Body.view template
            of
                Dynamic fn ->
                    fn deviceConfig model

                Static fn ->
                    Html.Styled.map never <| fn deviceConfig

        innerView =
            [ Laf.responsiveMeta
            , Laf.fonts
            , Laf.style deviceConfig
            , Css.Global.global global
            , pageView
            ]

        debugStyle =
            Css.Global.global <|
                TheSett.Debug.global deviceConfig
    in
    case model.debug of
        True ->
            div [] (debugStyle :: innerView)

        False ->
            div [] innerView


viewForPage : Page -> ( Layout Msg Model, Template Msg Model )
viewForPage page =
    case page of
        LoadSchema ->
            ( Layouts.Landing.layout, Pages.LoadSchema.view )

        EndPoints ->
            ( Layouts.Explore.layout, Pages.EndPoints.view )

        DataModel ->
            ( Layouts.Explore.layout, Pages.DataModel.view )
