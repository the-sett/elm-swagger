module Index.Index exposing (Index, empty, fromMaybeString, fromString, fromStrings, indexToTrie, union)

import Set exposing (Set)
import Trie exposing (Trie)


type Index
    = Index (Set String)


empty : Index
empty =
    Index Set.empty


fromString : String -> Index
fromString val =
    String.words val
        |> Set.fromList
        |> Index


fromMaybeString : Maybe String -> Index
fromMaybeString maybeVal =
    case maybeVal of
        Nothing ->
            empty

        Just val ->
            fromString val


fromStrings : List String -> Index
fromStrings vals =
    List.map String.words vals
        |> List.concat
        |> Set.fromList
        |> Index


union : Index -> Index -> Index
union (Index set1) (Index set2) =
    Set.union set1 set2
        |> Index


indexToTrie : Index -> Trie ()
indexToTrie (Index vals) =
    Set.foldl
        (\val accum -> Trie.add ( val, () ) val accum)
        Trie.empty
        vals
