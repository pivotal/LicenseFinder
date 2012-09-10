Feature: License Finder command line executable

  Scenario: I want to check if any of my dependencies are not approved
    Given I have a rails application with license finder
    And my rails app depends on a gem "gpl_licensed_gem" licensed with "GPL"
    And my rails app depends on a gem "mit_licensed_gem" licensed with "MIT"
    And I whitelist the "MIT" license
    When I run "license_finder"
    Then I should see "gpl_licensed_gem" in its output
    And I should not see "mit_licensed_gem" in its output
    And it should exit with status code 1

  Scenario: I want my build to pass when all dependencies are approved
    Given I have a rails application with license finder
    And my rails app depends on a gem "mit_licensed_gem" licensed with "MIT"
    And I whitelist the following licenses: "MIT, other"

    When I run "license_finder"
    Then it should exit with status code 0
    And I should see "All gems are approved for use" in its output
