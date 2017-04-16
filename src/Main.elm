module Main exposing (main)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = model
        , view = view
        , update = update
        }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Noop ->
            model

        Choose i ->
            { model | chosen = Just i }

        Unchoose ->
            { model | chosen = Nothing }


type Msg
    = Noop
    | Choose Int
    | Unchoose


type alias Model =
    { options : List SurveyOption, chosen : Maybe Int }


model : Model
model =
    { options = (List.sortBy .place kitties.options)
    , chosen = Nothing
    }


view : Model -> Html Msg
view model =
    Html.div
        []
        [ Html.div [ Attr.class "title" ] [ Html.text "Choose a Kitty" ]
        , Html.div
            [ Attr.class "allKitties" ]
            [ Html.table []
                [ Html.tr []
                    (List.map (drawKitty model.chosen) model.options)
                ]
            ]
        ]


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
