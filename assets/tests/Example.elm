module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    test "it can run tests" <|
      \_ -> Expect.true "Expected this shit to be true" True
