@bdd
Feature: Task list
  As someone tracking things to do
  I want to add, complete, and remove tasks
  So I can see what's still pending

  Scenario: Adding a task makes it pending
    Given an empty task list
    When I add the task "buy milk"
    Then the pending tasks are "buy milk"

  Scenario: Completing a task removes it from pending
    Given an empty task list
    And I add the task "buy milk"
    When I complete the task "buy milk"
    Then there are no pending tasks

  Scenario: Completing an unknown task fails
    Given an empty task list
    When I try to complete the task "does not exist"
    Then it fails because the task was not found
