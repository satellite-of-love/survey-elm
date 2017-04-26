module SurveyOptions exposing (Survey, SurveyOption, loadOptions, decodeSurveyOption, decodeSurveyOptionsResponse, kitties)

import Json.Decode as Decode


type alias SurveyOption =
    { imageLocation : String, text : String, place : Int }


type alias Survey =
    { surveyName : String, options : List SurveyOption }


loadOptions : Survey -> List SurveyOption
loadOptions r =
    (List.sortBy .place (.options r))


kitties : Survey
kitties =
    { surveyName = "Fallback Kitties"
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


decodeSurveyOptionsResponse : Decode.Decoder Survey
decodeSurveyOptionsResponse =
    Decode.map2 Survey
        (Decode.field "surveyName" Decode.string)
        (Decode.field "options" (Decode.list decodeSurveyOption))


decodeSurveyOption : Decode.Decoder SurveyOption
decodeSurveyOption =
    Decode.map3 SurveyOption
        (Decode.field "imageLocation" Decode.string)
        (Decode.field "text" Decode.string)
        (Decode.field "place" Decode.int)
