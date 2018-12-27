module TodoistRest exposing (Cmd(..), Msg(..), Project, Token, apiUrl, getAllProjects, getProject)

import Dict
import Http exposing (Expect, expectJson, expectString)
import Iso8601
import Json.Decode exposing (Decoder, de, field, int, string)
import Json.Decode.Pipeline exposing (decoded, hardcoded, optional, required)
import Result exposing (Result)
import Time exposing (Posix)


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


type alias Due =
    { date : Posix
    , string : String
    , datetime : Maybe String
    , timezone : Maybe String
    }


type alias Task =
    { id : Int
    , projectId : Int
    , completed : Bool
    , content : String
    , labelIds : List Int
    , order : Int
    , indent : Int
    , priority : Int
    , due : Due
    , url : String
    , commentCount : Int
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
