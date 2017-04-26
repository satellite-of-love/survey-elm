module SurveyOptions exposing (Survey, SurveyOption, loadOptions, decodeSurveyOption, decodeSurvey, kitties, encodeSurvey, encodeSurveyOption)

import Json.Decode as Decode
import Json.Encode as Encode


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


decodeSurvey : Decode.Decoder Survey
decodeSurvey =
    Decode.map2 Survey
        (Decode.field "surveyName" Decode.string)
        (Decode.field "options" (Decode.list decodeSurveyOption))


decodeSurveyOption : Decode.Decoder SurveyOption
decodeSurveyOption =
    Decode.map3 SurveyOption
        (Decode.field "imageLocation" Decode.string)
        (Decode.field "text" Decode.string)
        (Decode.field "place" Decode.int)


encodeSurveyOption : SurveyOption -> Encode.Value
encodeSurveyOption so =
    Encode.object
        [ ( "imageLocation", Encode.string so.imageLocation )
        , ( "place", Encode.int so.place )
        , ( "text", Encode.string so.text )
        ]


encodeSurvey : Survey -> Encode.Value
encodeSurvey sr =
    Encode.object
        [ ( "surveyName", Encode.string sr.surveyName )
        , ( "options", Encode.list (List.map encodeSurveyOption sr.options) )
        ]
