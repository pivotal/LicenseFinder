Feature: Tracking Node Dependencies
  So that I can track Node dependencies
  As an application developer using license finder
  I want to be able to manage Node dependencies

  Scenario: See the dependencies from the package file
    Given A package file with dependencies
    When I run license_finder
    Then I should see a Node dependency with a license