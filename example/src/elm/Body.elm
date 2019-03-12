module Body exposing (view)

import Html.Styled exposing (div, styled)
import Html.Styled.Attributes exposing (class, title)
import Structure exposing (Template(..))
import TheSett.Laf as Laf


view : Template msg model -> Template msg model
view template =
    (\devices model ->
        styled div
            [ Laf.wrapper devices ]
            []
            [ case template of
                Dynamic fn ->
                    fn devices model

                Static fn ->
                    Html.Styled.map never <| fn devices
            ]
    )
        |> Dynamic
