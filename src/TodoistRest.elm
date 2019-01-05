module TodoistRest exposing
    ( Token, Project, Task, Due, Label
    , getAllProjects, getProject
    , getActiveTasks, getActiveTask
    , getLabel, getAllLabels
    )

{-| This library provides functions for integration with the Todoist rest Api.


# Data types

@docs Token, Project, Task, Due, Label


# Api calls


## Projects

@docs getAllProjects, getProject


## Tasks

@docs getActiveTasks, getActiveTask

## Labels

@docs getLabel, getAllLabels

-}

import Dict
import Http exposing (Expect, expectJson, expectString)
import Iso8601
import Json.Decode exposing (Decoder, bool, field, int, string)
import Json.Decode.Pipeline exposing (optional, required)
import Result exposing (Result)
import Time exposing (Posix)


apiUrl : String -> String
apiUrl moduleName =
    "https://beta.todoist.com/API/v8/" ++ moduleName


{-| A todoist access token. This is needed for all calls to the api.
This can be found on: <https://todoist.com/prefs/integrations> at the very bottom of the page.
-}
type alias Token =
    String


{-| The Todoist Project type represents a project in todoist. It has the
following values:

    * id: Integer - The project unique id on the Todoist platform
    * name: String - The name of the project
    * order: Int - The order of the projects in the users setup
    * indent: Int - An int ranging from 1 to 4 for the project indentation level.
    * commentCount: Int - The amount of comments on a project.

-}
type alias Project =
    { id : Int
    , name : String
    , order : Int
    , indent : Int
    , commentCount : Int
    }


{-| The Due type represents a due date.
It has the following values:

    * date : String - This is a String telling when the due time is.
    * string : String - A human readable representation of the due date
    * datetime : String - A datetime representing the die date
    * timezone : String - The timezone the datetime is set in

-}
type alias Due =
    { date : String --TODO make date a Posix instead of string
    , string : String
    , datetime : Maybe String
    , timezone : Maybe String
    }


{-| The task type represents a todoist task.
It has the following values:

    * id : Int - The task unique id in Todoist
    * projectId : Int - The id of the project the task is in
    * completed : Bool - If the task is completed or not
    * labelIds : List Int - A list of all associated label ids
    * order : Int - The order of the task in the project it is in
    * indent : Int - Indention level of the task in the project
    * priority : Int - The priority of the task, takes on a value from 1 to 4.
    * due : Maybe Due - A due object telling when the task is due, Nothing if no due date is specified
    * url : String - The permanent link to the task page on Todoist.com
    * commentCount : Int - The amount of comments on the task.

-}
type alias Task =
    { id : Int
    , projectId : Int
    , completed : Bool
    , content : String
    , labelIds : List Int
    , order : Int
    , indent : Int
    , priority : Int
    , due : Maybe Due
    , url : String
    , commentCount : Int
    }


{-| The label type represents a Todoist label.
It has the following values:

    * id : Int - The label unique id in Todoist
    * name : String - The label name
    * order : Int - The order number of the label in the list of all labels.

-}
type alias Label =
    { id : Int
    , name : String
    , order : Int
    }


{-| Makes a get request with correct headers and body for the Todoist api.
The first parameter is which url to ask on, the second is an Expect to indicate
how to interpret the answer and the third is the token used to make the request with.

This function is not supposed to be exposed. If a certain kind of request to the api is
not already written as a seperate function write one and expose that instead.

-}
todoistGetRequest : String -> Expect msg -> Token -> Cmd msg
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


{-| Makes a get request for all the projects associated with the provided token.
-}
getAllProjects : (Result Http.Error (List Project) -> msg) -> Token -> Cmd msg
getAllProjects msg =
    todoistGetRequest (apiUrl "projects") (Http.expectJson msg (Json.Decode.list projectDecoder))


{-| Makes a get request for the project associated with the provided id.
Will fail if the provided token does not grant access to the project.
-}
getProject : (Result Http.Error Project -> msg) -> Int -> Token -> Cmd msg
getProject msg id =
    todoistGetRequest (apiUrl "projects/" ++ String.fromInt id) (Http.expectJson msg projectDecoder)


{-| Makes a get request for all the active tasks associated with the provided token.
-}
getActiveTasks : (Result Http.Error (List Task) -> msg) -> Token -> Cmd msg
getActiveTasks msg =
    todoistGetRequest (apiUrl "tasks") (Http.expectJson msg (Json.Decode.list taskDecoder))


{-| Makes a get request for the task associated with the provided id.
-}
getActiveTask : (Result Http.Error (List Task) -> msg) -> Int -> Token -> Cmd msg
getActiveTask msg id =
    todoistGetRequest (apiUrl "tasks/" ++ String.fromInt id) (Http.expectJson msg (Json.Decode.list taskDecoder))


{-| Makes a get request for all the labels associated with the provided token.
-}
getAllLabels : (Result Http.Error (List Label) -> msg) -> Token -> Cmd msg
getAllLabels msg =
    todoistGetRequest (apiUrl "labels") (Http.expectJson msg (Json.Decode.list labelDecoder))


{-| Makes a get request for the label associated with the provided id.
-}
getLabel : (Result Http.Error Label -> msg) -> Int -> Token -> Cmd msg
getLabel msg id =
    todoistGetRequest (apiUrl "labels/" ++ String.fromInt id) (Http.expectJson msg labelDecoder)


{-| Decoder for the Project type
-}
projectDecoder : Decoder Project
projectDecoder =
    Json.Decode.map5 Project
        (field "id" int)
        (field "name" string)
        (field "order" int)
        (field "indent" int)
        (field "comment_count" int)


{-| Decoder for the Due type
-}
dueDecoder : Decoder Due
dueDecoder =
    Json.Decode.succeed Due
        |> required "date" string
        |> required "string" string
        |> optional "datetime" (Json.Decode.map Just string) Nothing
        |> optional "timezone" (Json.Decode.map Just string) Nothing


{-| Decoder for the Label type
-}
labelDecoder : Decoder Label
labelDecoder =
    Json.Decode.succeed Label
        |> required "id" int
        |> required "name" string
        |> required "order" int


{-| Decoder for the Task type
-}
taskDecoder : Decoder Task
taskDecoder =
    Json.Decode.succeed Task
        |> required "id" int
        |> required "project_id" int
        |> required "completed" bool
        |> required "content" string
        |> required "label_ids" (Json.Decode.list int)
        |> required "order" int
        |> required "indent" int
        |> required "priority" int
        |> optional "due" (Json.Decode.maybe dueDecoder) Nothing
        |> required "url" string
        |> required "comment_count" int
