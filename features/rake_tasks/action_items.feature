Feature: rake license:action_items
  As a user
  I want a rake task "license:action_items" that lists any dependencies with licenses that fall outside of my whitelist
  So that I know the limitations of distributing my application

  Background:
    Given I have a rails application with license finder

  Scenario: Application with non-free dependency
    Given my rails app depends on a gem "gpl_licensed_gem" licensed with "GPL"
    And my rails app depends on a gem "mit_licensed_gem" licensed with "MIT"
    And I whitelist the "MIT" license
    When I run "rake license:action_items"
    Then I should see "gpl_licensed_gem" in its output
    And I should not see "mit_licensed_gem" in its output

  Scenario: Application with action items
    Given my rails app depends on a gem "gpl_licensed_gem" licensed with "GPL"
    And I whitelist the "MIT" license
    When I run "rake license:action_items"
    Then it should exit with status code 1

  Scenario: Application with no action items
    Given I whitelist the following licenses: "MIT, ruby, other"
    When I run "rake license:action_items"
    Then I should see "All gems are approved for use" in its output
    And it should exit with status code 0
