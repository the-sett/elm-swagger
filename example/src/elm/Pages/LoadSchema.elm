module Pages.LoadSchema exposing (view)

import Css
import Grid
import Html.Styled exposing (div, h1, p, styled, text)
import Html.Styled.Attributes exposing (id)
import Html.Styled.Lazy exposing (lazy)
import Structure exposing (Template(..))
import Styles exposing (lg, md, sm, xl)
import TheSett.Buttons as Buttons


view : Template msg model
view =
    (\devices ->
        div
            []
            [ div [ id "load schema" ] []
            , p [] [ text <| "Load Schema" ]
            ]
    )
        |> lazy
        |> Static
