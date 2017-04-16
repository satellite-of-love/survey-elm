module Main exposing (main)

import Html exposing (Html)


main : Html never
main =
    Html.div []
        [ Html.text "Hello World"
        , Html.div [] []
        ]


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
