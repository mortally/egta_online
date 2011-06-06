Feature: Scheduler schedules simulations
  In order to simplify simulation scheduling
  As a developer
  I want all profiles to be scheduled at once

@wip
Scenario: Game scheduler schedules all of its profiles as they are added
  Given 1 simulator
  And 1 run time configuration
  And that run time configuration belongs to that simulator
  And that simulator has the following game scheduler:
    | size | 2 |
  And that game scheduler belongs to that simulator
  When I add strategy "A" to that game scheduler
  Then I should have 1 simulation scheduled
  And that simulation should have profile "A: 2"
  And that simulation should have state "pending"
  When I add strategy "B" to that game scheduler
  Then I should have 3 simulations scheduled
  And all simulations should have state "pending"
