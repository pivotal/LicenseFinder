Feature: Approving non-whitelisted Dependencies
  So that I can track the dependencies of my application which my business has approved
  As an application developer using license finder
  I want to be able to manually approve dependencies that have licenses which fall outside of my whitelist

  Scenario: Approving a non-whitelisted dependency via the `license_finder` command
    Given I have an app with license finder
    And my app depends on a gem "gpl_gem" licensed with "GPL"
    When I run "license_finder"
    Then I should see "gpl_gem" in its output
    When I run "license_finder -a gpl_gem"
    When I run "license_finder"
    Then I should not see "gpl_gem" in its output
    Then I should see the "gpl_gem" in the html flagged as "approved"
