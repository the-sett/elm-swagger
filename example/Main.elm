port module Main exposing (..)

import Json.Encode as Encode
import Swagger exposing (..)
import Swagger.Encoder exposing (EncoderProgram, encodeSpecProgram)


apiSpec : Spec
apiSpec =
    Swagger


main : EncoderProgram
main =
    encodeSchemaProgram apiSpec emit


port emit : String -> Cmd a
