module ApiTest exposing (all)

import Api exposing (defaultTaskRequestParameters)
import Expect exposing (Expectation)
import Test exposing (..)
import Url.Builder


all : Test
all =
    describe "Test suite for the ApiTest module"
        [ test "A known query with a filter should be url encoded" <|
            \_ ->
                Expect.equal
                    (Api.url <| Api.TaskSearch { defaultTaskRequestParameters | filter = Just "##Personal" })
                    ((Api.url <| Api.TaskSearch defaultTaskRequestParameters) ++ "?filter=%23%23Personal")
        , test "queryParameters with a set filter should just return a single url parameter" <|
            \_ ->
                let
                    filter =
                        "someFilter"
                in
                Expect.equal
                    (Url.Builder.toQuery <|
                        Api.queryParameters (Api.TaskSearch { defaultTaskRequestParameters | filter = Just filter })
                    )
                    ("?filter=" ++ filter)
        ]
