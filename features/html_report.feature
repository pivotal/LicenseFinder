Feature: HTML Report
  So that I can easily view a report outlining my application dependencies and licenses
  As a non-technical application product owner
  I want license finder to generate an easy-to-understand HTML report

  Background:
    Given I have an app with license finder

  Scenario: Dependency details listed in HTML report
    And my app depends on a gem with specific details
    When I run license_finder
    Then I should see my project name
    And I should see my specific gem details listed in the html

  Scenario: Approval status of dependencies indicated in HTML report
    And my app depends on MIT and GPL licensed gems
    When I whitelist the MIT license
    Then I should see the GPL gem unapproved in html
    And the MIT gem approved in html

  Scenario: Dependency summary
    And my app depends on MIT and GPL licensed gems
    When I whitelist MIT and 'other' and New BSD licenses
    Then I should see only see GPL liceneses as unapproved in the html
