module Main exposing (main)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Random
import Http
import SurveyOptions exposing (SurveyOption, SurveyOptionsResponse)
import SurveyResult exposing (SurveyResult, SurveyResultResponse)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }


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
            , fetchSurveyOptions ( i, 3 )
            )

        NewSurveyPlease ->
            ( { model | seed = 0, chosen = Nothing }
            , Random.generate NewRandomSeed (Random.int 1 1000)
            )

        SurveyOptionsHaveArrived result ->
            case result of
                Ok surveyOptionResults ->
                    ( { model
                        | seed = surveyOptionResults.seed
                        , options = Success (SurveyOptions.loadOptions surveyOptionResults)
                      }
                    , Cmd.none
                    )

                Err boo ->
                    ( { model
                        | options = Failure boo
                      }
                    , Cmd.none
                    )

        Vote options choice ->
            ( { model | chosen = Nothing, summary = Loading }
            , sendVote ( options, choice )
            )

        SurveyResultResponseHasArrived (Ok result) ->
            ( { model | summary = Success ("Got it: " ++ (toString result)) }, Cmd.none )

        SurveyResultResponseHasArrived (Err boo) ->
            ( { model | summary = Failure boo }, Cmd.none )


type Msg
    = Noop
    | Choose Int
    | Unchoose
    | NewSurveyPlease
    | NewRandomSeed Int
    | SurveyOptionsHaveArrived (Result Http.Error SurveyOptionsResponse)
    | Vote (List SurveyOption) Int
    | SurveyResultResponseHasArrived (Result Http.Error SurveyResultResponse)



-- It is strangely difficult to access a list by index


findChoiceText : List SurveyOption -> Int -> String
findChoiceText options place =
    options
        |> List.filter (\e -> e.place == place)
        |> List.head
        |> Maybe.map .text
        |> Maybe.withDefault "WAT"


type alias Model =
    { seed : Int
    , options : RemoteData Http.Error (List SurveyOption)
    , chosen : Maybe Int
    , summary : RemoteData Http.Error String
    }


init : ( Model, Cmd Msg )
init =
    ( { seed = 123
      , options = Loading
      , chosen = Nothing
      , summary = NotAsked
      }
    , fetchSurveyOptions ( 123, 3 )
    )


view : Model -> Html Msg
view model =
    let
        tableContent =
            case model.options of
                Success options ->
                    (List.map (drawKitty model.chosen) options)

                NotAsked ->
                    [ Html.td [] [ Html.text "Consider clicking 'New Survey'" ] ]

                Loading ->
                    [ Html.td [] [ Html.text "Wait for it ... " ] ]

                Failure boo ->
                    [ Html.td [] [ Html.text ("Failure !!" ++ (toString boo)) ] ]

        summaryContent =
            case model.summary of
                NotAsked ->
                    ""

                Loading ->
                    "sending vote..."

                Success s ->
                    s

                Failure boo ->
                    "Boo! Failure! " ++ (toString boo)
    in
        Html.div
            []
            [ Html.div [ Attr.class "titleBar" ]
                [ Html.div [ Attr.class "title" ] [ Html.text "Choose a Kitty" ]
                , Html.div [ Attr.class "survey-number" ] [ Html.text ("Survey #" ++ (toString model.seed)) ]
                ]
            , Html.div
                [ Attr.class "allKitties" ]
                [ Html.table []
                    [ Html.tr []
                        tableContent
                    ]
                ]
            , Html.div [] [ voteButton model, newSurveyButton ]
            , Html.div [] [ Html.text summaryContent ]
            , Html.hr [] []
            , Html.div [ Attr.class "footer" ] [ Html.a [ Attr.href "https://github.com/satellite-of-love/survey-elm/tree/gh-pages" ] [ Html.text "Source" ] ]
            ]


voteButton : Model -> Html Msg
voteButton model =
    case ( model.chosen, model.options ) of
        ( Just kitteh, Success opts ) ->
            Html.button [ Html.Events.onClick (Vote opts kitteh) ] [ Html.text "Vote" ]

        _ ->
            Html.button [ Attr.disabled True ] [ Html.text "Vote" ]


newSurveyButton : Html Msg
newSurveyButton =
    Html.button [ Html.Events.onClick NewSurveyPlease ] [ Html.text "New Survey" ]


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



--- HTTP


type RemoteData e a
    = NotAsked
    | Loading
    | Failure e
    | Success a


fetchSurveyOptions : ( Int, Int ) -> Cmd Msg
fetchSurveyOptions ( seed, choices ) =
    let
        url =
            "https://survey.atomist.com/survey-options/surveyOptions?seed=" ++ (toString seed) ++ "&count=" ++ (toString choices)

        request =
            Http.get url SurveyOptions.decodeSurveyOptionsResponse
    in
        Http.send SurveyOptionsHaveArrived request


sendVote : ( List SurveyOption, Int ) -> Cmd Msg
sendVote ( options, choice ) =
    let
        url =
            "https://survey.atomist.com/survey-results/vote"

        body =
            Http.jsonBody (SurveyResult.encodeSurveyResult (SurveyResult options choice))

        request =
            Http.post url body SurveyResult.decodeSurveyResultResponse
    in
        Http.send SurveyResultResponseHasArrived request
