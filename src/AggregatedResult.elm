module AggregatedResult exposing (AggregatedResultResponse, decodeAggregatedResultResponse, orderedCounts)

import Json.Decode as Decode


type alias Place =
    Int


type alias Count =
    Int


type alias AggregatedResultResponse =
    { survey : { surveyName : String }
    , results : List ( Place, Count )
    }


orderedCounts : AggregatedResultResponse -> List Count
orderedCounts arr =
    let
        first ( a, _ ) =
            a

        second ( _, b ) =
            b
    in
        List.sortBy first arr.results |> List.map second


decodeAggregatedResultResponse : Decode.Decoder AggregatedResultResponse
decodeAggregatedResultResponse =
    let
        tuple a b =
            ( a, b )

        justTheSurveyName n =
            { surveyName = n }
    in
        Decode.map2 AggregatedResultResponse
            (Decode.field "survey" (Decode.map justTheSurveyName (Decode.field "surveyName" Decode.string)))
            (Decode.field "results" (Decode.list (Decode.map2 tuple Decode.int Decode.int)))
