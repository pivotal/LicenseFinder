Feature: Ignore Groups
  As a developer
  I want to ignore certain groups
  So that any gems I use in development, or for testing, are automatically approved for use

  Scenario: Groups can be ignored
    Given I have an app
    And I ignore the test group
    When I get the ignored groups
    Then I should see the test group in the output

  Scenario: Ignored groups are not evaluated for licenses
    Given I have an app that depends on a gem in the test group
    And I ignore the test group
    When I run license_finder
    Then I should not see the test gem in the output

  Scenario: Groups can be removed from the ignore list
    Given I have an app
    And I ignore the test group
    And I stop ignoring the test group
    When I get the ignored groups
    Then I should not see the test group in the output
