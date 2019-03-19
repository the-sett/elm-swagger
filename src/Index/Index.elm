module Index.Index exposing (Index, empty)

import Set exposing (Set)


type Index
    = Index (Set String)


empty =
    Index Set.empty
