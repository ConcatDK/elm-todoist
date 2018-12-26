module Main exposing (main)

import Browser
import Html exposing (Html)
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
    = Loading
    | Failure
    | Success (List Todoist.Project)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, Cmd.map TodoistMessage <| Todoist.getAllProjects "TOKEN HERE" )


type Msg
    = TodoistMessage Todoist.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TodoistMessage message ->
            case message of
                Todoist.GotAllProjects result ->
                    case result of
                        Ok projects ->
                            ( Success projects, Cmd.none )

                        Err error ->
                            ( Failure, Cmd.none )


viewProject : Todoist.Project -> Html Msg
viewProject project =
    Html.div []
        [ Html.b [] [ Html.text project.name ]
        , Html.text ":"
        , Html.ul [] [
            Html.li [] [Html.text "id: ", Html.text <| String.fromInt project.id]
            , Html.li [] [Html.text "order: ", Html.text <| String.fromInt project.order]
            , Html.li [] [Html.text "indent: ", Html.text <| String.fromInt project.indent]
            , Html.li [] [Html.text "comment count: ", Html.text <| String.fromInt project.comment_count]
        ]
        ]


view : Model -> Html Msg
view model =
    case model of
        Loading ->
            Html.text "Loading data"

        Failure ->
            Html.text "Failed to fetch shiet"

        Success projects ->
            Html.div [] <| List.map viewProject projects
