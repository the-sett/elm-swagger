module Index.Index exposing (Index, empty, fromMaybeString, fromString, fromStrings, search, union)

import Set exposing (Set)
import Trie exposing (Trie)


type Index
    = Index
        { tags : Set String
        , trie : Trie ()
        }


empty : Index
empty =
    Index
        { tags = Set.empty
        , trie = Trie.empty
        }


fromString : String -> Index
fromString val =
    let
        words =
            String.words val
                |> Set.fromList
    in
    Index
        { tags = words
        , trie = tagsToTrie words
        }


fromMaybeString : Maybe String -> Index
fromMaybeString maybeVal =
    case maybeVal of
        Nothing ->
            empty

        Just val ->
            fromString val


fromStrings : List String -> Index
fromStrings vals =
    let
        words =
            List.map String.words vals
                |> List.concat
                |> Set.fromList
    in
    Index
        { tags = words
        , trie = tagsToTrie words
        }


union : Index -> Index -> Index
union (Index index1) (Index index2) =
    let
        words =
            Set.union index1.tags index2.tags
    in
    Index
        { tags = words
        , trie = tagsToTrie words
        }


tagsToTrie : Set String -> Trie ()
tagsToTrie tags =
    Set.foldl
        (\val accum -> Trie.add ( val, () ) val accum)
        Trie.empty
        tags


search : Index -> String -> Bool
search (Index index) term =
    Trie.expand term index.trie
        |> List.isEmpty
        |> not
