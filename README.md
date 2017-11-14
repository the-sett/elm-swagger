# Elm Swagger

Swagger specifications (now OpenApi 3.0) can be awkward to write correctly by hand. There are graphical tools to aid with this, but there is also a need to be able to construct correct specifications in code, for example, for code generation purposes.

Swagger specs make use of Json Schemas to define the types of data models that an API can pass over the wire. This tool builds on top of [NoRedInk/json-elm-schema](https://github.com/NoRedInk/json-elm-schema), for the Json Schema part, and is written in a style very similar to it. That is, it defines a DSL for building correct Swagger specifications, encoders/decoders for writing/reading Swagger specs as Json, and cli tools for supporting code generation.

# Status

This is work in progress, the aims are:

* DSL for creating Swagger specs in Elm.
* Encoders/Decoders for Swagger specs.
* cli tools for turning a Swagger spec into Elm code to interface with that API, on client and server side.

# Running the Swagger Specification cli tool.

This will convert a Swagger specification in the Elm DSL to its normal JSON format. See the [example/Main.elm](https://github.com/the-sett/elm-swagger/blob/master/example/Main.elm) for an example program that outputs a swagger specification suitable for running the cli tool against.

(Not yet available - as npm package not published) To install the tool and run it:

```sh
npm install -g elm-swagger
elm-swagger Main.elm > swagger.json
```

To install the tool and test it locally:

```sh
npm install cli
cd example
../node_modules/.bin/elm-swagger Main.elm > swagger.json
```
