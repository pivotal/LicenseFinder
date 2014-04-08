Feature: Approving non-whitelisted Dependencies
  So that I can track the dependencies of my application which my business has approved
  As an application developer using license finder
  I want to be able to manually approve dependencies that have licenses which fall outside of my whitelist

  Scenario: Approving a non-whitelisted dependency via the `license_finder` command
    Given I have an app with license finder that depends on a GPL licensed gem
    When I approve that gem
    Then I should not see that gem in the console output
    And I should see that gem approved in dependencies.html
