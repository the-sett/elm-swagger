module ViewUtils exposing (highlight, optionalFlagField, optionalTextField, uncurry)

import Colors
import Css
import Html.Styled exposing (div, span, styled, text)
import List.Extra
import Regex


optionalTextField : Maybe String -> String -> (a -> Maybe String) -> a -> Maybe (Html.Styled.Html msg)
optionalTextField maybeSearch label exFn rec =
    let
        maybeVal =
            exFn rec
    in
    case maybeVal of
        Nothing ->
            Nothing

        Just val ->
            Just <|
                div []
                    [ highlight maybeSearch <| label ++ ": " ++ val
                    ]


optionalFlagField : String -> (a -> Maybe Bool) -> a -> Maybe (Html.Styled.Html msg)
optionalFlagField label exFn rec =
    let
        maybeVal =
            exFn rec
    in
    case maybeVal of
        Nothing ->
            Nothing

        Just val ->
            Just <|
                div []
                    [ text <|
                        label
                            ++ ": "
                            ++ (if val then
                                    "true"

                                else
                                    "false"
                               )
                    ]


uncurry : (a -> b -> c) -> ( a, b ) -> c
uncurry fn =
    \( fst, snd ) -> fn fst snd


highlight : Maybe String -> String -> Html.Styled.Html msg
highlight maybeSearch val =
    case maybeSearch of
        Nothing ->
            text val

        Just search ->
            let
                attribute =
                    Css.backgroundColor <| Colors.highlight

                regex =
                    toRegex search

                matches =
                    Regex.find regex val |> List.map (\match -> styled span [ attribute ] [] [ text match.match ])

                rest =
                    Regex.split regex val |> List.map text
            in
            span [] (List.Extra.interweave rest matches)


toRegex : String -> Regex.Regex
toRegex string =
    if string == "" then
        Regex.never

    else
        Regex.fromStringWith { caseInsensitive = True, multiline = False } string |> Maybe.withDefault Regex.never
