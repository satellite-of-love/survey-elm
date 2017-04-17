module SurveyResult exposing (SurveyResult, SurveyResultResponse, decodeSurveyResultResponse, encodeSurveyResult)

import Json.Encode as Encode
import Json.Decode as Decode
import SurveyOptions exposing (SurveyOption)


type alias SurveyResult =
    { options : List SurveyOption
    , choice : Int
    }


type alias SurveyResultResponse =
    { option : SurveyOption }


type alias AggregateResult =
    { option : SurveyOption
    , votes : Int
    }


decodeAggregateResult : Decode.Decoder AggregateResult
decodeAggregateResult =
    Decode.map2 AggregateResult (Decode.field "option" SurveyOptions.decodeSurveyOption) (Decode.field "votes" Decode.int)


decodeSurveyResultResponse : Decode.Decoder SurveyResultResponse
decodeSurveyResultResponse =
    SurveyOptions.decodeSurveyOption
        |> Decode.field "option"
        |> Decode.map SurveyResultResponse


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
        [ ( "options", Encode.list (List.map encodeSurveyOption sr.options) )
        , ( "choice", Encode.int sr.choice )
        ]
