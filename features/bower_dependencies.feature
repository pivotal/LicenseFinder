Feature: Tracking Bower Dependencies
  So that I can track Bower dependencies
  As an application developer using license finder
  I want to be able to manage Bower dependencies

  Scenario: See the dependencies from the bower.json file
    Given A bower.json file with dependencies
    When I run license_finder
    Then I should see a Bower dependency with a license