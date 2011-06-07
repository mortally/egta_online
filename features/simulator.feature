Feature: Upload a simulator
  In order to run simulations with a self-contained simulator
  As a testbed user
  I want to upload my simulator to nyx cluster via testbed interface

Scenario: Access a new simulator page
  Given I am signed in 
  And I am on the simulators page
  When I follow "New Simulator"
  Then I am on the new simulator page
 
Scenario: Upload a new simulator
  Given I am signed in
  And I am on the new simulator page
  When I fill in the following:
  | Name | scpp_sim |
  | Version | 0.97 |
  | Description | Self-confirming price prediction simulator |
  And I attach the file "features/sim/scpp_sim.zip" to "Simulator source"
  And I press "Create Simulator"
  Then I should have the simulator with the name "scpp_sim"
 
 Scenario: Upload a new simulator without simulator source specified
  Given I am signed in
  And I am on the new simulator page
  When I fill in the following:
  | Name | scpp_sim |
  | Version | 0.97 |
  | Description | Self-confirming price prediction simulator |
  And I press "Create Simulator"
  Then I should not have the simulator with the name "scpp_sim"

