Feature: Tracking non-Bundler Dependencies
  So that I can track JS and other dependencies not tracked by Bundler
  As an application developer using license finder
  I want to be able to manually manage non-Bundler dependencies

  Scenario: Adding a non-Bundler dependency
    Given I have an app with license finder
    When I add my JS dependency
    Then I should see the JS dependency in the console output

  Scenario: Removing a non-Bundler dependency
    Given I have an app with license finder and a JS dependency
    When I remove my JS dependency
    Then I should not see the JS dependency in the console output
