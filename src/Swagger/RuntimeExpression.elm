module Swagger.RuntimeExpression exposing (Expression(..), RequestExp(..), ResponseExp(..))

{-| The spec describes RuntimeExpressions, which are schemas describing callbacks and links.

      expression = ( "$url" | "$method" | "$statusCode" | "$request." source | "$response." source )
      source = ( header-reference | query-reference | path-reference | body-reference )
      header-reference = "header." token
      query-reference = "query." name
      path-reference = "path." name
      body-reference = "body" ["#" fragment]
      fragment = a JSON Pointer [RFC 6901](https://tools.ietf.org/html/rfc6901)
      name = *( char )
      char = as per RFC [7159](https://tools.ietf.org/html/rfc7159#section-7)
      token = as per RFC [7230](https://tools.ietf.org/html/rfc7230#section-3.2.6)

-}


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
