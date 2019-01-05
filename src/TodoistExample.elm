module TodoistExample exposing (main)

import Browser
import Html exposing (Html)
import Html.Events as Event
import Http
import String
import TodoistRest as Todoist


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }


type Model
    = NoToken
    | Loading
    | Failure String
    | SuccessProjects (List Todoist.Project)
    | SuccessTasks (List Todoist.Task)


init : () -> ( Model, Cmd Msg )
init _ =
    ( NoToken, Cmd.none )


type Msg
    = ProvidedNewProjectToken Todoist.Token
    | ReceivedNewProjects (Result Http.Error (List Todoist.Project))
    | ProvidedNewTaskToken Todoist.Token
    | ReceivedNewTasks (Result Http.Error (List Todoist.Task))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ProvidedNewProjectToken token ->
            ( Loading, Todoist.getAllProjects ReceivedNewProjects token )

        ProvidedNewTaskToken token ->
            ( Loading, Todoist.getActiveTasks ReceivedNewTasks token )

        ReceivedNewProjects result ->
            case result of
                Err error ->
                    ( Failure (Debug.toString error), Cmd.none )

                Ok projects ->
                    ( SuccessProjects projects, Cmd.none )

        ReceivedNewTasks result ->
            case result of
                Err error ->
                    ( Failure (Debug.toString error), Cmd.none )

                Ok tasks ->
                    ( SuccessTasks tasks, Cmd.none )


viewProject : Todoist.Project -> Html Msg
viewProject project =
    Html.div []
        [ Html.b [] [ Html.text project.name ]
        , Html.text ":"
        , Html.ul []
            [ Html.li [] [ Html.text "id: ", Html.text <| String.fromInt project.id ]
            , Html.li [] [ Html.text "order: ", Html.text <| String.fromInt project.order ]
            , Html.li [] [ Html.text "indent: ", Html.text <| String.fromInt project.indent ]
            , Html.li [] [ Html.text "comment count: ", Html.text <| String.fromInt project.commentCount ]
            ]
        ]


viewTask : Todoist.Task -> Html msg
viewTask task =
    Html.div []
        [ Html.b [] [ Html.text task.content ]
        , Html.text ":"
        , Html.ul []
            [ Html.li [] [ Html.text "id: ", Html.text <| String.fromInt task.id ]
            , Html.li [] [ Html.text "order: ", Html.text <| String.fromInt task.order ]
            , Html.li [] [ Html.text "priority: ", Html.text <| String.fromInt task.priority ]
            ]
        ]


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.form []
            [ Html.input [ Event.onInput ProvidedNewProjectToken ] [ Html.text "Provide a token for projects" ]
            , Html.input [ Event.onInput ProvidedNewTaskToken ] [ Html.text "Provide a token for tasks" ]
            ]
        , Html.br [] []
        , case model of
            NoToken ->
                Html.text "No token has been provided. Give me one!"

            Loading ->
                Html.text "Loading all your shiet - plz wait"

            Failure errorMessage ->
                Html.text <| "Failed to fetch shiet. Here is your error message: " ++ errorMessage

            SuccessProjects projects ->
                Html.div [] <| List.map viewProject projects

            SuccessTasks tasks ->
                Html.div [] <| List.map viewTask <| List.filter (\t -> t.priority == 4 ) tasks
        ]
