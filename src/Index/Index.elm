module Index.Index exposing (Index, empty, fromString, fromStrings, union)

import Set exposing (Set)


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
