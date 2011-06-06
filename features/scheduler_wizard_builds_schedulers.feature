Feature: Scheduler wizard builds schedulers
  In order to build the site without AJAX
  As a developer
  I want a multistep wizard for creating schedulers

Background:
  Given I am signed in

Scenario: Game schedulers can be created
  Given the following simulator:
    | name    | epp_sim |
    | version | testing0 |
  And I am on the new game scheduler page
  When I fill in the following:
    | Max samples            | 10   |
    | Samples per simulation | 5    |
    | Process memory (in MB) | 1000 |
    | Time per sample        | 40   |
    | Jobs per request       | 2    |
  And I press "Create Game Scheduler"
  Then I should see "Select Simulator"
  When I select "epp_sim-testing0" from "Simulator"
  And I press "Choose Simulator"
  Then I should see "Set Run Time Configuration"
  When I fill in "A" with "3"
  And I press "Set Configuration"
  Then I should see "Game Scheduler was successfully created."
  And I should see the following table rows:
    | Simulator              | epp_sim-testing0 |
    | Max samples            | 10               |
    | Samples per simulation | 5                |
    | Process memory (in MB) | 1000             |
    | Time per sample        | 40               |
    | Jobs per request       | 2                |
    | A                      | 3                |

















