module Main exposing (..)

import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Visualization.Axis as Axis exposing (defaultOptions)
import Visualization.List as List
import Visualization.Scale as Scale exposing (ContinuousScale, ContinuousTimeScale)
import Visualization.Shape as Shape
import Http exposing (..)
import Debug
import Data exposing (decoded)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Http
import Task


-- MAIN --


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }



-- MODEL --


type alias User =
    { age : Int
    , rating : Int
    }


type alias Model =
    { users : List User
    , xLabel : String
    , yLabel : String
    }


initialModel =
    Model [] "Age" "Rating"


init : ( Model, Cmd Msg )
init =
    initialModel ! [ (Http.send NewData (Http.get "./data.json" usersDecoder)) ]


usersDecoder : Decode.Decoder (List User)
usersDecoder =
    let
        userDecoder =
            decode User
                |> required "age" Decode.int
                |> required "rating" Decode.int
    in
        Decode.list userDecoder



-- UPDATE --


type Msg
    = NoOp
    | NewData (Result Error (List User))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        NewData result ->
            case result of
                Ok users ->
                    { model | users = users } ! []

                Err s ->
                    Debug.log (toString s)
                        |> (\_ -> model ! [])



-- VIEW --


w : Float
w =
    900


h : Float
h =
    450


padding : Float
padding =
    30



-- Scales


xScale : ContinuousScale
xScale =
    Scale.linear ( 0, 100 ) ( 0, w - 2 * padding )


yScale : ContinuousScale
yScale =
    Scale.linear ( 0, 100 ) ( h - 2 * padding, 0 )


xAxis : Svg msg
xAxis =
    Axis.axis { defaultOptions | orientation = Axis.Bottom, tickCount = 10 } xScale


yAxis : Svg msg
yAxis =
    Axis.axis { defaultOptions | orientation = Axis.Left, tickCount = 10 } yScale


transformToLineData : ( Float, Float ) -> Maybe ( Float, Float )
transformToLineData ( x, y ) =
    Just ( Scale.convert xScale x, Scale.convert yScale y )


line : List User -> Svg.Attribute msg
line users =
    users
        |> List.map (\{ age, rating } -> transformToLineData ( toFloat age, toFloat rating ))
        |> Shape.line Shape.linearCurve
        |> d


view : Model -> Html Msg
view { users } =
    svg [ width (toString w ++ "px"), height (toString h ++ "px") ]
        [ g [ transform ("translate(" ++ toString (padding - 1) ++ ", " ++ toString (h - padding) ++ ")") ]
            [ xAxis ]
        , g [ transform ("translate(" ++ toString (padding - 1) ++ ", " ++ toString padding ++ ")") ]
            [ yAxis ]
        , g [ transform ("translate(" ++ toString padding ++ ", " ++ toString padding ++ ")") ]
            [ Svg.path [ line (List.sortBy .age users), stroke "black", strokeWidth "3px", fill "none" ] []
            ]
        ]
