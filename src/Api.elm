module Api exposing (ModuleRequest(..), defaultTaskRequestParameters, url, queryParameters)

import Maybe.Extra
import Url
import Url.Builder as Builder exposing (QueryParameter)


{-| Represents a request to a Todoist module with the associated parameters
-}
type ModuleRequest
    = ProjectSearch
    | TaskSearch
        { projectId : Maybe Int
        , labelId : Maybe Int
        , filter : Maybe String
        , lang : Maybe String
        }
    | LabelSearch
    | ProjectIdGet Int
    | TaskIdGet Int
    | LabelIdGet Int


{-| Returns the absolute path of a ModuleRequest as a string
-}
pathString : ModuleRequest -> String
pathString moduleRequest =
    Builder.absolute
        (List.append [ "API", "v8" ]
            (case moduleRequest of
                ProjectSearch ->
                    [ "projects" ]

                TaskSearch _ ->
                    [ "tasks" ]

                LabelSearch ->
                    [ "labels" ]

                ProjectIdGet id ->
                    [ "projects", String.fromInt id ]

                TaskIdGet id ->
                    [ "tasks", String.fromInt id ]

                LabelIdGet id ->
                    [ "labels", String.fromInt id ]
            )
        )
    <|
        queryParameters moduleRequest


{-| Creates the request url corresponding to a ModuleRequest.
-}
url : ModuleRequest -> String
url moduleRequest =
    Url.toString <|
        Url.Url
            Url.Https
            "beta.todoist.com"
            Nothing
            (pathString moduleRequest)
            Nothing
            Nothing


{-| Returns a list of appropriate QueryParameters given a ModuleRequest
-}
queryParameters : ModuleRequest -> List QueryParameter
queryParameters moduleRequest =
    case moduleRequest of
        TaskSearch parameters ->
            Maybe.Extra.values
                [ Maybe.map (Builder.int "project_id") parameters.projectId
                , Maybe.map (Builder.int "label_id") parameters.labelId
                , Maybe.map (Builder.string "filter") parameters.filter
                , Maybe.map (Builder.string "lang") parameters.lang
                ]

        _ ->
            []


{-| The default parameters for a query. It will usually be a good idea to construct QueryParameters
by replacing fields in this function.

A way to make a request for tasks with id 42:

    queryWithFilter =
        url <| TaskRequest { defaultTaskQueryParameters | projectId = Just 42 }

-}
defaultTaskRequestParameters :
    { projectId : Maybe Int
    , labelId : Maybe Int
    , filter : Maybe String
    , lang : Maybe String
    }
defaultTaskRequestParameters =
    { projectId = Nothing
    , labelId = Nothing
    , filter = Nothing
    , lang = Nothing
    }
