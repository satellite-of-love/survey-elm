module AggregatedResult exposing (AggregatedResultResponse, decodeAggregatedResultResponse, orderedCounts)

import Json.Decode as Decode


type alias Place =
    Int


type alias Count =
    Int


type alias PlaceAndCount =
    { place : Int, count : Int }


type alias AggregatedResultResponse =
    { survey : { surveyName : String }
    , results : List PlaceAndCount
    }


orderedCounts : AggregatedResultResponse -> List Count
orderedCounts arr =
    List.sortBy .place arr.results |> List.map .count


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
            (Decode.field "results"
                (Decode.list
                    (Decode.map2 PlaceAndCount (Decode.field "count" Decode.int) (Decode.field "place" Decode.int))
                )
            )
