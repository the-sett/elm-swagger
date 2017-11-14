# Elm Swagger

Work in progress, the aims are:

* DSL for creating Swagger specs in Elm.
* Encoders/Decoders for Swagger specs.
* cli tools for turning a Swagger spec into Elm code to interface with that API, on client and server side.

# Running the Swagger Specification cli tool.

This will convert a Swagger specification in the Elm DSL to its normal JSON format. See the example/Main.elm for an example program that outputs a swagger specification suitable for running the cli tool against.

(Not yet available - as npm package not published) To install the tool and run it:

```sh
npm install -g elm-swagger
elm-swagger Main.elm > swagger.json
```

To install the too and test it locally:

```sh
npm install cli
cd example
../node_modules/.bin/elm-swagger Main.elm > swagger.json
```
