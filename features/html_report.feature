Feature: HTML Report
  So that I can easily view a report outlining my application dependencies and licenses
  As a non-technical application product owner
  I want license finder to generate an easy-to-understand HTML report

  Background:
    Given I have an app with license finder

  Scenario: Dependency details listed in HTML report
    Given my application depends on a gem "mit_licensed_gem" with:
      | license | summary     | description | version | homepage                           | bundler_groups |
      | MIT     | mit is cool | seriously   | 0.0.1   | http://mit_licensed_gem.github.com | test           |
    When I run "license_finder"
    And I should see the "mit_licensed_gem" in the html with the following details:
      | license | summary     | description | name                    | bundler_groups |
      | MIT     | mit is cool | seriously   | mit_licensed_gem v0.0.1 | test           |
    And the text "MIT" should link to "http://opensource.org/licenses/mit-license"
    And the text "mit_licensed_gem" should link to "http://mit_licensed_gem.github.com"

  Scenario: Approval status of dependencies indicated in HTML report
    Given my app depends on a gem "gpl_licensed_gem" licensed with "GPL"
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    And I whitelist the "MIT" license
    When I run "license_finder"
    Then I should see the "gpl_licensed_gem" in the html flagged as "unapproved"
    And I should see the "mit_licensed_gem" in the html flagged as "approved"

  Scenario: Dependency summary
    Given my app depends on a gem "gpl_licensed_gem" licensed with "GPL"
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    And I whitelist the following licenses: "MIT, other"
    When I run "license_finder"
    # rake, bundler, license_finder, my_app, gpl_licensed_gem, mit_licensed_gem
    Then I should see "8 total" in the html
    # gpl_licensed_gem
    And I should see "1 unapproved" in the html
    # gpl_licensed_gem
    And I should see "1 GPL" in the html
