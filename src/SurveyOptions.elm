module SurveyOptions exposing (SurveyOptionsResponse, SurveyOption, loadOptions, decodeSurveyOption, decodeSurveyOptionsResponse, kitties)

import Json.Decode as Decode


type alias SurveyOption =
    { imageLocation : String, text : String, place : Int }


type alias SurveyOptionsResponse =
    { seed : Int, surveyName : String, options : List SurveyOption }


loadOptions : SurveyOptionsResponse -> List SurveyOption
loadOptions r =
    (List.sortBy .place (.options r))


kitties : SurveyOptionsResponse
kitties =
    { seed = 123
    , surveyName = "Fallback Kitties"
    , options =
        [ { imageLocation = "images/kitty1.jpg"
          , text = "Loki standing"
          , place = 1
          }
        , { imageLocation = "images/kitty2.jpg"
          , text = "Grimm standing"
          , place = 3
          }
        , { imageLocation = "images/kitty4.jpg"
          , text = "cuddling kitties"
          , place = 2
          }
        ]
    }


decodeSurveyOptionsResponse : Decode.Decoder SurveyOptionsResponse
decodeSurveyOptionsResponse =
    Decode.map3 SurveyOptionsResponse
        (Decode.field "seed" Decode.int)
        (Decode.field "surveyName" Decode.string)
        (Decode.field "options" (Decode.list decodeSurveyOption))


decodeSurveyOption : Decode.Decoder SurveyOption
decodeSurveyOption =
    Decode.map3 SurveyOption
        (Decode.field "imageLocation" Decode.string)
        (Decode.field "text" Decode.string)
        (Decode.field "place" Decode.int)
