module SurveyOptions exposing (SurveyOptionsResponse, SurveyOption, decodeSurveyOptionsResponse, kitties)

import Json.Decode as Decode


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


decodeSurveyOptionsResponse : Decode.Decoder SurveyOptionsResponse
decodeSurveyOptionsResponse =
    Decode.map3 SurveyOptionsResponse
        (Decode.field "seed" Decode.int)
        (Decode.field "count" Decode.int)
        (Decode.field "options" (Decode.list decodeSurveyOption))


decodeSurveyOption : Decode.Decoder SurveyOption
decodeSurveyOption =
    Decode.map3 SurveyOption
        (Decode.field "imageLocation" Decode.string)
        (Decode.field "text" Decode.string)
        (Decode.field "place" Decode.int)
