Feature: Project names
  As a developer
  I want to assign a name for my project
  So that license audit reports indicate their associated project

  Scenario: Specifying a project name
    Given I have an app
    When I set the project name to new_project
    And I run license_finder
    Then I should see the project name new_project in the html
