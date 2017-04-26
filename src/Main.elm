module Main exposing (main)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Random
import Http
import SurveyOptions exposing (SurveyOption, Survey)
import SurveyResult exposing (SurveyResult, SurveyResultResponse)
import AggregatedResult exposing (AggregatedResultResponse)
import VersionInfo exposing (versionInfo)


surveyOptionsBaseUrl : String
surveyOptionsBaseUrl =
    "https://survey.atomist.com/philly"



-- sendVoteBaseUrl : String
-- sendVoteBaseUrl =
--     "https://survey.atomist.com/london"
-- aggregatedResultsBaseUrl : String
-- aggregatedResultsBaseUrl =
--     "https://survey.atomist.com/london"


aggregatedResultsBaseUrl : String
aggregatedResultsBaseUrl =
    "http://localhost:8091"


sendVoteBaseUrl =
    "http://localhost:8091"


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }


type alias Model =
    { seed : Int
    , surveyName : String
    , options : RemoteData Http.Error (List SurveyOption)
    , chosen : Maybe Int
    , voteResponse : RemoteData Http.Error SurveyResultResponse
    , results : RemoteData Http.Error AggregatedResultResponse
    }


init : ( Model, Cmd Msg )
init =
    ( { seed = 1
      , surveyName = "Nothing Yet"
      , options = Loading
      , chosen = Nothing
      , voteResponse = NotAsked
      , results = NotAsked
      }
    , fetchSurveyOptions 1
    )


type Msg
    = Noop
    | Choose Int
    | Unchoose
    | NewSurveyPlease
    | NewRandomSeed Int
    | SurveyOptionsHaveArrived (Result Http.Error Survey)
    | Vote String (List SurveyOption) Int
    | SurveyResultResponseHasArrived (Result Http.Error SurveyResultResponse)
    | AggregatedResultHasArrived (Result Http.Error AggregatedResultResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        Choose i ->
            ( { model | chosen = Just i }, Cmd.none )

        Unchoose ->
            ( { model | chosen = Nothing }, Cmd.none )

        NewRandomSeed i ->
            ( { model
                | seed = i
                , options = Loading
              }
            , fetchSurveyOptions i
            )

        NewSurveyPlease ->
            ( { model | seed = 0, chosen = Nothing }
            , Random.generate NewRandomSeed (Random.int 1 10)
            )

        SurveyOptionsHaveArrived result ->
            case result of
                Ok survey ->
                    ( { model
                        | surveyName = survey.surveyName
                        , options = Success (SurveyOptions.loadOptions survey)
                        , results = NotAsked
                      }
                    , Cmd.none
                    )

                Err boo ->
                    ( { model
                        | surveyName = "Fallback Kitties"
                        , options = Success (.options SurveyOptions.kitties)
                      }
                    , Cmd.none
                    )

        Vote name options choice ->
            ( { model | chosen = Nothing, voteResponse = Loading }
            , sendVote ( name, options, choice )
            )

        SurveyResultResponseHasArrived (Ok result) ->
            ( { model | voteResponse = Success result, results = Loading }
            , fetchAggregatedResults result.surveyName
            )

        SurveyResultResponseHasArrived (Err boo) ->
            ( { model | voteResponse = Failure boo }, Cmd.none )

        AggregatedResultHasArrived (Ok result) ->
            ( { model | results = Success result }, Cmd.none )

        AggregatedResultHasArrived (Err boo) ->
            ( { model | results = Failure boo }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        tableContent =
            case model.options of
                Success options ->
                    (List.map (drawKitty model.chosen) (List.sortBy .place options))

                NotAsked ->
                    [ Html.td [] [ Html.text "Consider clicking 'New Survey'" ] ]

                Loading ->
                    [ Html.td [] [ Html.text "Wait for it ... " ] ]

                Failure boo ->
                    [ Html.td [] [ Html.text ("Failure !!" ++ (toString boo)) ] ]

        voteResponseContent =
            case model.voteResponse of
                NotAsked ->
                    ""

                Loading ->
                    "sending vote..."

                Success s ->
                    "You voted for: " ++ s.option.text

                Failure boo ->
                    "Boo! Failure! " ++ (toString boo)

        resultTableContent =
            case model.results of
                Success arr ->
                    (List.map drawCount (AggregatedResult.orderedCounts arr))

                NotAsked ->
                    [ Html.td [] [] ]

                Loading ->
                    [ Html.td [] [ Html.text "Wait for it ... " ] ]

                Failure boo ->
                    [ Html.td [] [ Html.text ("Failure !!" ++ (toString boo)) ] ]
    in
        Html.div
            []
            [ Html.div [ Attr.class "titleBar" ]
                [ Html.div [ Attr.class "survey-name" ] [ Html.text model.surveyName ]
                , Html.div [ Attr.class "title" ] [ Html.text "Choose a Kitty" ]
                , Html.div [ Attr.class "seed" ] [ Html.text ("seed:" ++ (toString model.seed)) ]
                ]
            , Html.div
                [ Attr.class "allKitties" ]
                [ Html.table []
                    [ Html.tr []
                        tableContent
                    ]
                ]
            , Html.div [] [ voteButton model, newSurveyButton ]
            , Html.div [] [ Html.text voteResponseContent ]
            , Html.div
                [ Attr.class "allVotes" ]
                [ Html.table []
                    [ Html.tr []
                        resultTableContent
                    ]
                ]
            , Html.hr [] []
            , Html.div [ Attr.class "footer" ] [ Html.a [ Attr.href "https://github.com/satellite-of-love/survey-elm/tree/gh-pages" ] [ Html.text versionInfo.version ] ]
            ]


voteButton : Model -> Html Msg
voteButton model =
    case ( model.chosen, model.options ) of
        ( Just kitteh, Success opts ) ->
            Html.button [ Html.Events.onClick (Vote model.surveyName opts kitteh) ] [ Html.text "Vote" ]

        _ ->
            Html.button [ Attr.disabled True ] [ Html.text "Vote" ]


newSurveyButton : Html Msg
newSurveyButton =
    Html.button [ Html.Events.onClick NewSurveyPlease ] [ Html.text "New Survey" ]


drawCount : Int -> Html Msg
drawCount i =
    Html.td [] [ Html.text ((toString i) ++ " votes") ]


drawKitty : Maybe Int -> SurveyOption -> Html Msg
drawKitty chosen kitty =
    let
        itIsMe =
            case chosen of
                Just i ->
                    kitty.place == i

                _ ->
                    False
    in
        Html.td
            [ Html.Events.onClick
                (if itIsMe then
                    Unchoose
                 else
                    Choose kitty.place
                )
            , Attr.classList [ ( "kitty", True ), ( "chosen", itIsMe ) ]
            , Attr.style [ ( "background-image", "url(" ++ kitty.imageLocation ++ ")" ) ]
            ]
            []



-- It is strangely difficult to access a list by index


findChoiceText : List SurveyOption -> Int -> String
findChoiceText options place =
    options
        |> List.filter (\e -> e.place == place)
        |> List.head
        |> Maybe.map .text
        |> Maybe.withDefault "WAT"


type RemoteData e a
    = NotAsked
    | Loading
    | Failure e
    | Success a


fetchSurveyOptions : Int -> Cmd Msg
fetchSurveyOptions seed =
    let
        url =
            surveyOptionsBaseUrl
                ++ "/surveyOptions?seed="
                ++ (toString seed)

        request =
            Http.get url SurveyOptions.decodeSurveyOptionsResponse
    in
        Http.send SurveyOptionsHaveArrived request


fetchAggregatedResults : String -> Cmd Msg
fetchAggregatedResults surveyName =
    let
        url =
            aggregatedResultsBaseUrl
                ++ "/aggregatedResults?surveyName="
                ++ surveyName

        request =
            Http.get url AggregatedResult.decodeAggregatedResultResponse
    in
        Http.send AggregatedResultHasArrived request


sendVote : ( String, List SurveyOption, Int ) -> Cmd Msg
sendVote ( name, options, choice ) =
    let
        url =
            sendVoteBaseUrl ++ "/vote"

        body =
            Http.jsonBody (SurveyResult.encodeSurveyResult (SurveyResult name options choice))

        request =
            Http.post url body SurveyResult.decodeSurveyResultResponse
    in
        Http.send SurveyResultResponseHasArrived request
