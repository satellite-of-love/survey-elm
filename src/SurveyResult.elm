module SurveyResult exposing (SurveyResult, SurveyResultResponse, decodeSurveyResultResponse, encodeSurveyResult)

import Json.Encode as Encode
import Json.Decode as Decode
import SurveyOptions exposing (SurveyOption)


type alias SurveyResult =
    { surveyName : String
    , options : List SurveyOption
    , choice : Int
    }


type alias SurveyResultResponse =
    { surveyName : String
    , option : SurveyOption
    }


decodeSurveyResultResponse : Decode.Decoder SurveyResultResponse
decodeSurveyResultResponse =
    Decode.map2 SurveyResultResponse
        (Decode.field "surveyName" Decode.string)
        (Decode.field "option" SurveyOptions.decodeSurveyOption)


encodeSurveyOption : SurveyOption -> Encode.Value
encodeSurveyOption so =
    Encode.object
        [ ( "imageLocation", Encode.string so.imageLocation )
        , ( "place", Encode.int so.place )
        , ( "text", Encode.string so.text )
        ]


encodeSurveyResult : SurveyResult -> Encode.Value
encodeSurveyResult sr =
    Encode.object
        [ ( "surveyName", Encode.string sr.surveyName )
        , ( "options", Encode.list (List.map encodeSurveyOption sr.options) )
        , ( "choice", Encode.int sr.choice )
        ]
