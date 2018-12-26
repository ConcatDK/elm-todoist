module Main exposing (main)

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
    | Loading Todoist.Token
    | Failure
    | Success (List Todoist.Project)


init : () -> ( Model, Cmd Msg )
init _ =
    ( NoToken, Cmd.none )


type Msg
    = TodoistMessage Todoist.Msg
    | NewToken Todoist.Token


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

        NewToken token ->
            ( Loading token, Cmd.map TodoistMessage <| Todoist.getAllProjects token )


viewProject : Todoist.Project -> Html Msg
viewProject project =
    Html.div []
        [ Html.b [] [ Html.text project.name ]
        , Html.text ":"
        , Html.ul []
            [ Html.li [] [ Html.text "id: ", Html.text <| String.fromInt project.id ]
            , Html.li [] [ Html.text "order: ", Html.text <| String.fromInt project.order ]
            , Html.li [] [ Html.text "indent: ", Html.text <| String.fromInt project.indent ]
            , Html.li [] [ Html.text "comment count: ", Html.text <| String.fromInt project.comment_count ]
            ]
        ]


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.form []
            [ Html.input [ Event.onInput NewToken ] [] ]
        , Html.br [] []
        , case model of
            NoToken ->
                Html.text "No token has been provided. Give me one!"

            Loading token ->
                Html.text "Loading data"

            Failure ->
                Html.text "Failed to fetch shiet - check if the token is okay"

            Success projects ->
                Html.div [] <| List.map viewProject projects
        ]
