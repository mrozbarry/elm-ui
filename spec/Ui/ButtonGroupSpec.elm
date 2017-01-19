import Spec exposing (describe, it, Node, context)
import Spec.Assertions exposing (assert)
import Spec.Steps exposing (click)
import Spec.Runner

import Html exposing (div)

import Ui.ButtonGroup
import Ui.Container
import Ui.Styles

type alias Model
  = Ui.ButtonGroup.Model Msg

type Msg
  = Set

init : () -> Model
init _ =
  Ui.ButtonGroup.init
    [ ( "A", Set )
    , ( "B", Set )
    , ( "C", Set )
    ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Set ->
      ( model, Cmd.none )

view : Model -> Html.Html Msg
view model =
  div
    [ ]
    [ Ui.Styles.embed
    , Ui.ButtonGroup.view model
    ]

specs : Node
specs =
  describe "Ui.Button"
    [ context "First button"
      [ it "has rounded corners on the left side"
        [ assert.styleEquals
          { selector = "ui-button:first-child"
          , style = "border-radius"
          , value = "2px 0px 0px 2px"
          }
        ]
      ]
    , context "Middle buttons"
      [ it "has no rounded borders"
        [ assert.styleEquals
          { selector = "ui-button:nth-child(2)"
          , style = "border-radius"
          , value = "0px"
          }
        ]
      ]
    , context "Last button"
      [ it "has rounded corners on the right side"
        [ assert.styleEquals
          { selector = "ui-button:last-child"
          , style = "border-radius"
          , value = "0px 2px 2px 0px"
          }
        ]
      ]
    ]

main =
  Spec.Runner.runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    } specs