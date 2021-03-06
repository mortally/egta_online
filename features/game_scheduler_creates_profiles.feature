Feature: Game scheduler creates profiles
  In order to transition to virtual games
  As a developer
  I want schedulers to take on the responsibility of creating profiles

Scenario: Profile generation works for two strategies
  Given I am signed in
  And 1 simulator
  And that simulator has the strategy array "['A', 'B']"
  And I am on the game scheduler show page
  When I select "A" from "strategy"
  And I press "Add"
  And I select "B" from "strategy"
  And I press "Add"
  Then I should be on the game scheduler show page
  And I should see the following table rows:
    | Name       | Samples   |
    | A: 2       | 0 samples |
    | A: 1, B: 1 | 0 samples |
    | B: 2       | 0 samples |

Scenario: Profile already exists with the same run time configuration
  Given I am signed in
  Given 1 simulator
  And that simulator has the strategy array "['A', 'B']"
  And that simulator has the following profile:
    | proto_string | A, A |
  And the profile_entry of that profile has a sample
  And I am on the game scheduler show page
  When I select "A" from "strategy"
  And I press "Add"
  When I select "B" from "strategy"
  And I press "Add"
  Then there should be 3 profiles
  And I should be on the game scheduler show page
  And I should see the following table rows:
    | Name       | Samples   |
    | A: 2       | 1 sample |
    | A: 1, B: 1 | 0 samples |
    | B: 2       | 0 samples |