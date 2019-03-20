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


search : Index -> String -> Bool
search (Index index) term =
    Trie.expand (String.toLower term) index.trie
        |> List.isEmpty
        |> not


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
