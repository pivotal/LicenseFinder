Feature: Tracking Maven Dependencies
  So that I can track Maven dependencies
  As an application developer using license finder
  I want to be able to manage Maven dependencies

  Scenario: See the dependencies from the requirements file
    Given A pom file with dependencies
    When I run license_finder
    Then I should see a Maven dependency with a license