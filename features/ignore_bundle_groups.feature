Feature: Ignore Bundle Groups
  As a developer
  I want to ignore certain bundler groups
  So that any gems I use in development, or for testing, are automatically approved for use

  Scenario:
    Given I have an app with license finder
    And my application depends on a gem "gpl_gem" licensed with "GPL" in the "test" bundler groups
    And I whitelist the "test" bundler group
    When I run "license_finder"
    Then I should not see "gpl_gem" in its output
