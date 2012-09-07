Feature: rake license:action_items
  As a user
  I want a rake task "license:action_items" that lists any dependencies with licenses that fall outside of my whitelist
  So that I know the limitations of distributing my application

  Scenario: Application with non-free dependency
    Given I have a rails application with license finder
    And my rails app depends on a gem "gpl_licensed_gem" licensed with "GPL"
    And my rails app depends on a gem "mit_licensed_gem" licensed with "MIT"
    And I whitelist the "MIT" license
    When I run "bundle exec rake license:action_items"
    Then I should see "gpl_licensed_gem" in its output
    And I should not see "mit_licensed_gem" in its output
