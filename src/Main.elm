module Main exposing (main)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Random


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
            ( { model | seed = i }, Cmd.none )

        NewSurveyPlease ->
            ( { model | seed = 0 }
            , Random.generate NewRandomSeed (Random.int 1 1000)
            )


type Msg
    = Noop
    | Choose Int
    | Unchoose
    | NewSurveyPlease
    | NewRandomSeed Int


type alias Model =
    { seed : Int
    , options : List SurveyOption
    , chosen : Maybe Int
    }


init : ( Model, Cmd Msg )
init =
    ( { seed = 123
      , options = (List.sortBy .place kitties.options)
      , chosen = Nothing
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
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
                    (List.map (drawKitty model.chosen) model.options)
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


type alias SurveyOption =
    { imageLocation : String, text : String, place : Int }


type alias SurveyOptionsResponse =
    { seed : Int, count : Int, options : List SurveyOption }


kitties : SurveyOptionsResponse
kitties =
    { seed = 123
    , count = 3
    , options =
        [ { imageLocation = "https://c1.staticflickr.com/4/3149/2988746750_4a3dfdee59.jpg"
          , text = "sink kitties"
          , place = 1
          }
        , { imageLocation = "http://maxpixel.freegreatpicture.com/static/photo/1x/Sweet-Animals-Kitty-Cat-323262.jpg"
          , text = "kitty licking paw"
          , place = 3
          }
        , { imageLocation = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Computer-kitten.jpg/1024px-Computer-kitten.jpg"
          , text = "computer kitten"
          , place = 2
          }
        ]
    }
