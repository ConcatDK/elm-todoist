module TodoistRest exposing (Cmd(..), Msg(..), Project, Token, apiUrl, getAllProjects, getProject)

import Dict
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
    | GotProject (Result Http.Error Project)


type Cmd
    = GetAllProjects
    | GetProject Int


type alias Project =
    { id : Int
    , name : String
    , order : Int
    , indent : Int
    , comment_count : Int
    }


todoistGetRequest url expect token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , url = url
        , timeout = Nothing
        , expect = expect
        , tracker = Nothing
        }


getAllProjects =
    todoistGetRequest (apiUrl "projects") (Http.expectJson GotAllProjects projectListDecoder)


getProject id =
    todoistGetRequest (apiUrl "projects/" ++ String.fromInt id) (Http.expectJson GotProject projectDecoder)


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
