Feature: Manually Adding Dependencies
  So that I can track dependencies not managed by Bundler, NPM, etc.
  As an application developer using license finder
  I want to be able to manually add dependencies

  Scenario: Manually adding dependency
    Given I have an app
    When I add my JS dependency
    Then I should see the JS dependency in the console output

  Scenario: Auto approving a manually added dependency
    Given I have an app
    When I add my JS dependency with an approval flag
    Then I should not see the JS dependency in the console output

  Scenario: Removing a manually added dependency
    Given I have an app and a JS dependency
    When I remove my JS dependency
    Then I should not see the JS dependency in the console output
