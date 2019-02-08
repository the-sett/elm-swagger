module LoadSwagger exposing (Model, Msg, init, update, view)

import Html


type Model
    = Model


type Msg
    = Msg


init =
    Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    Html.text "load swagger"
