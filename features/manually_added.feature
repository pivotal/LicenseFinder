Feature: Tracking Unmanaged Dependencies
  So that I can track dependencies not managed by Bundler, NPM, etc.
  As an application developer using license finder
  I want to be able to manually track unmanaged dependencies

  Scenario: Adding a manually managed dependency
    Given I have an app with license finder
    When I add my JS dependency
    Then I should see the JS dependency in the console output

  Scenario: Auto approving a manually managed dependency I add
    Given I have an app with license finder
    When I add my JS dependency with an approval flag
    Then I should not see the JS dependency in the console output since it is approved

  Scenario: Removing a manually managed dependency
    Given I have an app with license finder and a JS dependency
    When I remove my JS dependency
    Then I should not see the JS dependency in the console output
