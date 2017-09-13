module Data exposing (decoded)

import Json.Decode as Decode


data : String
data =
    """[0,1,2,3,4,2,40,35,25,65,46,25,14,546,24,643,23,440,35,124,14,56,343,§2,34,11,23,554,233,121,343,43,25,653,23,54,23]"""



-- Main decoded


decoded : Result String (List Int)
decoded =
    Decode.decodeString (Decode.list (Decode.int)) data
