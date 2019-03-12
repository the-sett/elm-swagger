module Demo.Grid exposing (view)

import Css
import Grid
import Html.Styled exposing (div, h1, h4, styled, text)
import Html.Styled.Attributes exposing (id)
import Html.Styled.Lazy exposing (lazy)
import Structure exposing (Template(..))
import Styles exposing (lg, md, sm, xl)


view : Template msg model
view =
    (\devices ->
        div
            []
            [ div [ id "grids" ] []
            , styled h1
                [ Css.textAlign Css.center ]
                []
                [ text "Grids" ]
            , h4 [] [ text "Column Widths" ]
            , gridn devices widths
            , h4 [] [ text "Column Offsets" ]
            , gridn devices offsets
            , h4 [] [ text "Centered" ]
            , gridn devices centered
            , h4 [] [ text "End" ]
            , gridn devices end
            , h4 [] [ text "Auto Width" ]
            , gridn devices autoWidth
            , h4 [] [ text "Mixed Fixed and Auto Width" ]
            , gridn devices widthAndAuto
            ]
    )
        |> lazy
        |> Static


cellStyle =
    Styles.styles
        [ Css.backgroundColor <| Css.rgba 150 100 100 0.3
        , Css.property "box-shadow" "0 0 0 1px black inset"
        ]



-- Row generating functions


widths n =
    Grid.row []
        []
        [ Grid.col [ sm [ Grid.columns n, cellStyle ] ] [] [ text "cell" ] ]


offsets n =
    Grid.row []
        []
        [ Grid.col [ sm [ Grid.columns <| 13 - n, Grid.offset <| n - 1, cellStyle ] ] [] [ text "cell" ] ]


centered n =
    Grid.row [ sm [ Grid.center ] ]
        []
        [ Grid.col [ sm [ Grid.columns n, cellStyle ] ] [] [ text "cell" ] ]


end n =
    Grid.row [ sm [ Grid.end ] ]
        []
        [ Grid.col [ sm [ Grid.columns n, cellStyle ] ] [] [ text "cell" ] ]


autoWidth n =
    Grid.row []
        []
    <|
        List.repeat (floor n) (Grid.col [ sm [ Grid.auto, cellStyle ] ] [] [ text "cell" ])


widthAndAuto n =
    Grid.row []
        []
        [ Grid.col [ sm [ Grid.columns n, cellStyle ] ] [] [ text "cell" ]
        , Grid.col [ sm [ Grid.auto, cellStyle ] ] [] [ text "cell" ]
        ]



-- Grid generating functions


gridn devices rowFn =
    Grid.grid
        [ sm [ Grid.columns 12 ] ]
        []
        (List.map rowFn <| List.map toFloat <| List.filter (\v -> modBy 3 v == 0) <| List.range 1 12)
        devices
