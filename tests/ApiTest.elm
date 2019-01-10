module ApiTest exposing (all)

import Expect exposing (Expectation)
import Test exposing (..)
import Api exposing (defaultTaskRequestParameters)


all : Test
all =
    describe "Test suite for the ApiTest module"
        [ test "A known query with a filter should be url encoded" <|
            \_ -> Expect.equal
                (Api.url <| Api.TaskSearch { defaultTaskRequestParameters | filter = Just "##Personal" })
                ((Api.url <| Api.TaskSearch defaultTaskRequestParameters) ++ "?filter=%23%23Personal")
        ]
