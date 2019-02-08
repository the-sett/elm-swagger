module UpdateUtils exposing (lift)

{-| Utils for update function boiler-plate.
-}


{-| Convenience function for lifting an update function for an inner model
and messages into a parent one.
-}
lift :
    (model -> submodel)
    -> (submodel -> model -> model)
    -> (subaction -> action)
    -> (subaction -> submodel -> ( submodel, Cmd subaction ))
    -> subaction
    -> model
    -> ( model, Cmd action )
lift get set tagger update action model =
    let
        ( updatedSubModel, msg ) =
            update action (get model)
    in
    ( set updatedSubModel model, Cmd.map tagger msg )
