Feature: Project names
  As a developer
  I want to assign a name for my project
  So that license audit reports indicate their associated project

  Background:
    Given I have an app
    And I set the project name to new_project

  Scenario: The project name appears in the html
    Then I should see the project name new_project in the html

  Scenario: The project name can be reported
    When I get the project name
    Then I should see the project name new_project in the output

  Scenario: The project name can be removed
    When I remove the project name
    Then I should not see the project name new_project in the html
