Feature: Tracking Python Dependencies
  So that I can track Python dependencies
  As an application developer using license finder
  I want to be able to manage Python dependencies

  Scenario: See the dependencies from the requirements file
    Given A requirements file with dependencies
    When I run license_finder
    Then I should see a Python dependency with a license