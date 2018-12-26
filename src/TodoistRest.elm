module TodoistRest exposing (apiUrl, getAllProjects, Token, Project, Msg(..), Cmd(..))

import Http exposing (Expect, expectJson, expectString)
import Json.Decode exposing (Decoder, field, int, string)
import Result exposing (Result)


apiUrl : String -> String
apiUrl moduleName =
    "https://beta.todoist.com/API/v8/" ++ moduleName


type alias Token =
    String


type Msg
    = GotAllProjects (Result Http.Error (List Project))

type Cmd
    = GetAllProjects


type alias Project =
    { id : Int
    , name : String
    , order : Int
    , indent : Int
    , comment_count : Int
    }

getAllProjects token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , url = apiUrl "projects"
        , timeout = Nothing
        , expect = Http.expectJson GotAllProjects projectListDecoder
        , tracker = Nothing
        }


projectDecoder : Decoder Project
projectDecoder =
    Json.Decode.map5 Project
        (field "id" int)
        (field "name" string)
        (field "order" int)
        (field "indent" int)
        (field "comment_count" int)


projectListDecoder : Decoder (List Project)
projectListDecoder =
    Json.Decode.list projectDecoder


