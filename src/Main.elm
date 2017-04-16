module Main exposing (main)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Random
import Http
import SurveyOptions exposing (SurveyOption, SurveyOptionsResponse)


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


type Msg
    = Noop
    | Choose Int
    | Unchoose
    | NewSurveyPlease
    | NewRandomSeed Int
    | SurveyOptionsHaveArrived (Result Http.Error SurveyOptionsResponse)


type alias Model =
    { seed : Int
    , options : RemoteData Http.Error (List SurveyOption)
    , chosen : Maybe Int
    }


init : ( Model, Cmd Msg )
init =
    ( { seed = 123
      , options = Loading
      , chosen = Nothing
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
            , Html.div [] [ newSurveyButton ]
            ]


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
