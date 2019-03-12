module Pages.DataModel exposing (view)

import Css
import Html.Styled exposing (div, h1, h2, h3, h4, li, ol, p, styled, text, ul)
import Html.Styled.Attributes exposing (id)
import Html.Styled.Lazy exposing (lazy)
import Structure exposing (Template(..))


view : Template msg model
view =
    (\devices ->
        div
            []
            [ div [ id "datamodel" ] []
            , p [] [ text <| "Data Model" ]
            ]
    )
        |> lazy
        |> Static
