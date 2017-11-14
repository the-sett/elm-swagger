port module Main exposing (..)

import Json.Encode as Encode
import Swagger exposing (..)
import Swagger.Encoder exposing (EncoderProgram, encodeSpecProgram)


apiSpec : Spec
apiSpec =
    swagger


main : EncoderProgram
main =
    encodeSpecProgram apiSpec emit


port emit : String -> Cmd a
