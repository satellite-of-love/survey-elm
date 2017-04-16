module Main exposing (main)

import Html exposing (Html)
import Html.Attributes as Attr


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = model
        , view = view
        , update = update
        }


update : Msg -> Model -> Model
update msg model =
    model


type Msg
    = Noop


type alias Model =
    { options : List SurveyOption, chosen : Maybe Int }


model : Model
model =
    { options = kitties.options
    , chosen = Nothing
    }


view : Model -> Html Msg
view model =
    Html.div
        []
        [ Html.div [ Attr.class "title" ] [ Html.text "Choose a Kitty" ]
        , Html.div [ Attr.class "allKitties" ] [ Html.table [] [ Html.tr [] (List.map drawKitty model.options) ] ]
        ]


drawKitty : SurveyOption -> Html Msg
drawKitty kitty =
    Html.td
        [ Attr.class "kitty"
        , Attr.style [ ( "background-image", "url(" ++ kitty.imageLocation ++ ")" ) ]
        ]
        []


type alias SurveyOption =
    { imageLocation : String, text : String }


type alias SurveyOptionsResponse =
    { seed : Int, count : Int, options : List SurveyOption }


kitties : SurveyOptionsResponse
kitties =
    { seed = 123
    , count = 3
    , options =
        [ { imageLocation = "https://c1.staticflickr.com/4/3149/2988746750_4a3dfdee59.jpg"
          , text = "sink kitties"
          }
        , { imageLocation = "http://maxpixel.freegreatpicture.com/static/photo/1x/Sweet-Animals-Kitty-Cat-323262.jpg"
          , text = "kitty licking paw"
          }
        , { imageLocation = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Computer-kitten.jpg/1024px-Computer-kitten.jpg"
          , text = "computer kitten"
          }
        ]
    }
