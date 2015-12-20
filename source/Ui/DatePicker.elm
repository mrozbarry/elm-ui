module Ui.DatePicker
  (Model, Action, init, update, view, setValue) where

{-| Date picker input component.

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs setValue
-}
import Html.Events exposing (onFocus, onBlur, onClick)
import Html.Attributes exposing (classList)
import Html exposing (node, div, text)
import Html.Extra exposing (onKeys)
import Html.Lazy

import Signal exposing (forwardTo)
import Dict

import Date.Format exposing (format)
import Date

import Ui.Helpers.Dropdown as Dropdown
import Ui.Calendar as Calendar
import Ui

{-| Representation of a date picker component:
  - **calendar** - The model of a calendar
  - **format** - The format of the date to render in the input
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **disabled** - Whether or not the chooser is disabled
  - **readonly** - Whether or not the dropdown is readonly
  - **open** - Whether or not the dropdown is open
-}
type alias Model =
  { calendar : Calendar.Model
  , closeOnSelect : Bool
  , format : String
  , open : Bool
  , disabled : Bool
  , readonly : Bool
  }

{-| Actions that a date picker can make:
  - **Focus** - Opens the dropdown
  - **Close** - Closes the dropdown
  - **Toggle** - Toggles the dropdown
  - **Decrement** - Selects the previous day
  - **Increment** - Selects the next day
  - **Calendar** - Calendar actions
-}
type Action
  = Focus
  | Nothing
  | Increment
  | Decrement
  | Close
  | Toggle
  | Calendar Calendar.Action

{-| Initializes a date picker with the given values.

    DatePicker.init date
-}
init : Date.Date -> Model
init date =
  { calendar = Calendar.init date
  , closeOnSelect = False
  , format = "%Y-%m-%d"
  , open = False
  , disabled = False
  , readonly = False
  }

{-| Updates a date picker. -}
update : Action -> Model -> Model
update action model =
  case action of
    Focus ->
      Dropdown.open model

    Close ->
      Dropdown.close model

    Toggle ->
      Dropdown.toggle model

    Decrement ->
      { model | calendar = Calendar.previousDay model.calendar }
        |> Dropdown.open

    Increment ->
      { model | calendar = Calendar.nextDay model.calendar }
        |> Dropdown.open

    Calendar act ->
      let
        updatedModel =
          { model | calendar = Calendar.update act model.calendar }
      in
        case act of
          Calendar.Select date ->
            if model.closeOnSelect then
              Dropdown.close updatedModel
            else
              updatedModel
          _ -> updatedModel

    _ -> model

{-| Renders a date picker. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Renders a date picker.
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    actions =
      if model.disabled || model.readonly then []
      else [ onFocus address Focus
           , onClick address Focus
           , onBlur address Close
           , onKeys address Nothing
             (Dict.fromList [ (27, Close)
             , (13, Toggle)
             , (40, Increment)
             , (38, Decrement)
             , (39, Increment)
             , (37, Decrement)
             ])
           ]
  in
    node "ui-date-picker" ([ classList [ ("dropdown-open", model.open)
                                       , ("disabled", model.disabled)
                                       , ("readonly", model.readonly)
                                       ]
                           ] ++ actions ++ (Ui.tabIndex model))
      [ div [] [text (format model.format model.calendar.value)]
      , Ui.icon "calendar" False []
      , Dropdown.view []
        [ node "ui-dropdown-overlay" [onClick address Close] []
        , Calendar.view (forwardTo address Calendar) model.calendar
        ]
      ]

{-| Sets the value of a date picker -}
setValue : Date.Date -> Model -> Model
setValue date model =
  { model | calendar = Calendar.setValue date model.calendar }
