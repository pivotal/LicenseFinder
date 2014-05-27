Feature: Ignore Dependencies
  As a developer
  I want to ignore certain dependencies
  To avoid noisy doc changes when there are safe dependencies with high version churn

  Scenario: Select dependencies can be ignored
    Given I have an app that depends on bundler
    And I ignore the bundler dependency
    When I get the ignored dependencies 
    Then I should see 'bundler' in the output
    And I should not see 'bundler' in the dependency docs

  Scenario: Ignored dependencies do not appear in the unapproved list
    Given I have an app that depends on bundler
    And I ignore the bundler dependency
    When I run license_finder
    Then the generated dependencies do not contain bundler
