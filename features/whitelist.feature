Feature: Whitelist licenses
  As a developer
  I want to whitelist certain OSS licenses that my business has pre-approved
  So that any dependencies with those licenses do not show up as action items

  Scenario: Auditing an application with whitelisted licenses
    Given I have an app with license finder
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    When I run "license_finder"
    Then I should see "mit_licensed_gem" in its output
    When I whitelist the following licenses: "MIT, other"
    And I run "license_finder"
    Then I should see "All gems are approved for use" in its output
    And it should exit with status code 0

  Scenario: Whitelist with MIT License alternative name "Expat" should whitelist "MIT" licenses
    Given I have an app with license finder
    And "Expat" is an alternative name for the "MIT" license
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    When I run "license_finder"
    Then I should see "mit_licensed_gem" in its output
    When I whitelist the "Expat" license
    And I run "license_finder"
    Then I should not see "mit_licensed_gem" in its output
