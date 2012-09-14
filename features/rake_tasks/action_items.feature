Feature: rake license:action_items
  As a user
  I want a rake task "license:action_items" that lists any dependencies with licenses that fall outside of my whitelist
  So that I know the limitations of distributing my application

  Background:
    Given I have an application setup with rake and license finder

  Scenario: Application with non-free dependency
    Given my app depends on a gem "gpl_licensed_gem" licensed with "GPL"
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    And I whitelist the "MIT" license
    When I run "rake license:action_items"
    Then I should see "gpl_licensed_gem" in its output
    And I should not see "mit_licensed_gem" in its output

  Scenario: Application with action items
    Given my app depends on a gem "gpl_licensed_gem" licensed with "GPL"
    And I whitelist the "MIT" license
    When I run "rake license:action_items"
    Then it should exit with status code 1

  Scenario: Application with no action items
    Given I whitelist the "MIT" license
    When I run "rake license:action_items"
    Then I should see "All gems are approved for use" in its output
    And it should exit with status code 0

  Scenario: Generates HTML report
    Given my application depends on a gem "mit_licensed_gem" with:
      | license | summary     | description | version | homepage                           | bundler_groups |
      | MIT     | mit is cool | seriously   | 0.0.1   | http://mit_licensed_gem.github.com | test           |
    And my application depends on a gem "gpl_licensed_gem" with:
      | license | summary | description | version |
      | GPL     | gpl :-( | seriously   | 0.0.2   |
    And I whitelist the "MIT" license
    When I run "rake license:action_items"
    Then I should see the "gpl_licensed_gem" in the html flagged as "unapproved"
    And I should see the "mit_licensed_gem" in the html flagged as "approved"
    And I should see the "mit_licensed_gem" in the html with the following details:
      | license | summary     | description | name                    | bundler_groups |
      | MIT     | mit is cool | seriously   | mit_licensed_gem v0.0.1 | test           |
    And the text "MIT" should link to "http://opensource.org/licenses/mit-license"
    And the text "mit_licensed_gem" should link to "http://mit_licensed_gem.github.com"
    And I should see the "gpl_licensed_gem" in the html with the following details:
      | license | summary | description | name                    |
      | GPL     | gpl :-( | seriously   | gpl_licensed_gem v0.0.2 |
