module Swagger.CallbackExpression exposing (..)


type Expression
    = Url
    | Method
    | RequestExp Request
    | ResponseExp


type RequestExp
    = Path
    | Query
    | Header
    | Body


type ResponseExp
    = Header
