module Main exposing (init, update, view, Model, Msg)

{-| The content editor client top module.

@docs init, update, subscriptions, view, Model, Msg

-}

import Auth
import Browser
import Config exposing (config)
import Css
import Css.Global
import Grid
import Html
import Html.Styled exposing (div, form, h4, img, label, span, styled, text, toUnstyled)
import Html.Styled.Attributes exposing (for, name, src)
import Html.Styled.Events exposing (onClick, onInput)
import LoadSwagger
import Process
import Responsive
import Styles exposing (lg, md, sm, xl)
import Task
import TheSett.Buttons as Buttons
import TheSett.Cards as Cards
import TheSett.Debug
import TheSett.Laf as Laf exposing (devices, fonts, responsiveMeta, wrapper)
import TheSett.Textfield as Textfield
import Update3


{-| The content editor program model.
-}
type alias Model =
    { laf : Laf.Model
    , auth : Auth.Model
    , session : Session
    , username : String
    , password : String
    , debugStyle : Bool
    }


type Session
    = Initial
    | LoggedOut
    | FailedAuth
    | LoggedIn
        { scopes : List String
        , subject : String
        }


{-| The content editor program top-level message types.
-}
type Msg
    = LafMsg Laf.Msg
    | AuthMsg Auth.Msg
    | InitialTimeout
    | LogIn
    | TryAgain
    | UpdateUsername String
    | UpdatePassword String
    | ToggleGrid



-- Initialization


{-| Initializes the application state by setting it to the default Auth state
of LoggedOut.
Requests that an Auth refresh be performed to check what the current
authentication state is, as the application may be able to re-authenticate
from a refresh token held as a cookie, without needing the user to log in.
-}
init : flags -> ( Model, Cmd Msg )
init _ =
    ( { laf = Laf.init
      , auth =
            Auth.init
                { authApiRoot = config.authRoot
                }
      , session = LoggedIn { scopes = [], subject = "alice" }
      , username = ""
      , password = ""
      , debugStyle = False
      }
    , Cmd.none
      -- Process.sleep 1000 |> Task.perform (always InitialTimeout)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case Debug.log "msg" action of
        LafMsg lafMsg ->
            Laf.update LafMsg lafMsg model.laf
                |> Tuple.mapFirst (\laf -> { model | laf = laf })

        AuthMsg msg ->
            Update3.lift .auth (\x m -> { m | auth = x }) AuthMsg Auth.update msg model
                |> Update3.evalMaybe (\status -> \nextModel -> ( { nextModel | session = authStatusToSession status }, Cmd.none )) Cmd.none

        InitialTimeout ->
            ( model, Auth.refresh |> Cmd.map AuthMsg )

        LogIn ->
            ( model, Auth.login { username = model.username, password = model.password } |> Cmd.map AuthMsg )

        TryAgain ->
            ( { model | username = "", password = "" }, Auth.unauthed |> Cmd.map AuthMsg )

        UpdateUsername str ->
            ( { model | username = str }, Cmd.none )

        UpdatePassword str ->
            ( { model | password = str }, Cmd.none )

        ToggleGrid ->
            ( { model | debugStyle = not model.debugStyle }, Cmd.none )


authStatusToSession : Auth.Status -> Session
authStatusToSession status =
    case status of
        Auth.LoggedOut ->
            LoggedOut

        Auth.Failed ->
            FailedAuth

        Auth.LoggedIn access ->
            LoggedIn access



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
    { title = "Auth Elm Example"
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
            , case model.session of
                Initial ->
                    initialView

                LoggedOut ->
                    loginView model

                FailedAuth ->
                    notPermittedView model

                LoggedIn state ->
                    authenticatedView model state
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


initialView : Html.Styled.Html Msg
initialView =
    framing <|
        [ card "images/data_center-large.png"
            "Attempting to Restore"
            [ text "Attempting to restore authentication using a local refresh token." ]
            []
            devices
        ]


loginView : { a | laf : Laf.Model, username : String, password : String } -> Html.Styled.Html Msg
loginView model =
    framing <|
        [ card "images/data_center-large.png"
            "Log In"
            [ form []
                [ Textfield.text
                    LafMsg
                    [ 1 ]
                    model.laf
                    [ Textfield.value model.username ]
                    [ onInput UpdateUsername
                    ]
                    [ text "Username" ]
                    devices
                , Textfield.text
                    LafMsg
                    [ 2 ]
                    model.laf
                    [ Textfield.disabled
                    , Textfield.value model.password
                    ]
                    [ onInput UpdatePassword
                    ]
                    [ text "Password" ]
                    devices
                ]
            ]
            [ Buttons.button [] [ onClick LogIn ] [ text "Log In" ] devices
            ]
            devices
        ]


notPermittedView : { a | laf : Laf.Model, username : String, password : String } -> Html.Styled.Html Msg
notPermittedView model =
    framing <|
        [ card "images/data_center-large.png"
            "Not Authorized"
            [ form []
                [ Textfield.text
                    LafMsg
                    [ 1 ]
                    model.laf
                    [ Textfield.value model.username ]
                    [ onInput UpdateUsername
                    ]
                    [ text "Username" ]
                    devices
                , Textfield.text
                    LafMsg
                    [ 2 ]
                    model.laf
                    [ Textfield.disabled
                    , Textfield.value model.password
                    ]
                    [ onInput UpdatePassword
                    ]
                    [ text "Password" ]
                    devices
                ]
            ]
            [ Buttons.button [] [ onClick TryAgain ] [ text "Try Again" ] devices ]
            devices
        ]


authenticatedView : { a | username : String } -> { scopes : List String, subject : String } -> Html.Styled.Html Msg
authenticatedView model user =
    framing <|
        [ card "images/data_center-large.png"
            "Authenticated"
            [-- Lists.ul []
             --     [ Lists.li [ Lists.withBody ]
             --         [ Lists.content []
             --             [ text "Logged In As"
             --             , Lists.body [] [ text model.username ]
             --             ]
             --         ]
             --     , Lists.li [ Lists.withBody ]
             --         [ Lists.content []
             --             [ text "With Id"
             --             , Lists.body [] [ text user.subject ]
             --             ]
             --         ]
             --     , Lists.li [ Lists.withBody ]
             --         [ Lists.content []
             --             [ text "With Permissions"
             --             , Lists.body [] <| permissionsToChips user.scopes
             --             ]
             --         ]
             --     ]
            ]
            [ Buttons.button [] [ onClick TryAgain ] [ text "Try Again" ] devices ]
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
                [ Css.maxWidth <| Css.px 420
                , Css.minWidth <| Css.px 400
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
                [ Buttons.button
                    [ sm
                        [ Styles.styles
                            [ Css.position Css.absolute
                            , Css.bottom <| Css.em -3.5
                            , Css.right <| Css.em 2
                            , Css.backgroundColor <| Css.rgb 160 220 180
                            ]
                        ]
                    ]
                    [ onClick ToggleGrid ]
                    [ text "Grid" ]
                    devices
                ]
            ]
        , Cards.title title
        , Cards.body cardBody
        , Cards.controls controls
        ]
        devices


permissionsToChips : List String -> List (Html.Styled.Html Msg)
permissionsToChips permissions =
    -- List.map
    --     (\permission ->
    --         span [ class "mdl-chip mdl-chip__text" ]
    --             [ text permission ]
    --     )
    --     permissions
    []
