module Index.Index exposing
    ( Index
    , empty, addString, addStrings, addMaybeString, addIndex
    , prepare, search
    )

{-| Index provides an efficiently searchable indexing of strings.

@docs Index

@docs empty, addString, addStrings, addMaybeString, addIndex

@docs prepare, search

-}

import Set exposing (Set)
import Trie exposing (Trie)


type Index
    = Builder { tags : Set String }
    | Index { trie : Trie () }



-- Index builders.


empty : Index
empty =
    Builder { tags = Set.empty }


addString : String -> Index
addString val =
    let
        words =
            String.words val
                |> Set.fromList
    in
    Builder { tags = words }


addMaybeString : Maybe String -> Index
addMaybeString maybeVal =
    case maybeVal of
        Nothing ->
            empty

        Just val ->
            addString val


addStrings : List String -> Index
addStrings vals =
    let
        words =
            List.map String.words vals
                |> List.concat
                |> Set.fromList
    in
    Builder { tags = words }


addIndex : Index -> Index -> Index
addIndex index1 index2 =
    case ( index1, index2 ) of
        ( Builder b1, Builder b2 ) ->
            let
                words =
                    Set.union b1.tags b2.tags
            in
            Builder { tags = words }

        ( Builder b1, Index _ ) ->
            Builder b1

        ( Index _, Builder b2 ) ->
            Builder b2

        ( _, _ ) ->
            empty



-- Index preparation and search.


prepare : Index -> Index
prepare index =
    case index of
        Builder { tags } ->
            Index { trie = tagsToTrie tags }

        Index idx ->
            Index idx


search : Index -> String -> Bool
search index term =
    case index of
        Builder _ ->
            False

        Index { trie } ->
            Trie.expand (String.toLower term) trie
                |> List.isEmpty
                |> not



-- Helper functions.


tagsToTrie : Set String -> Trie ()
tagsToTrie tags =
    Set.foldl
        (\word accum ->
            List.foldl
                (\suffix innerAccum -> Trie.add ( word, () ) (String.toLower suffix) innerAccum)
                accum
                (suffixes word)
        )
        Trie.empty
        tags


suffixes : String -> List String
suffixes word =
    List.foldr
        (\c ( w, acc ) -> ( c :: w, String.fromList (c :: w) :: acc ))
        ( [], [] )
        (String.toList word)
        |> Tuple.second
