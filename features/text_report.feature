Feature: Text Report
  So that I can easily view a report outlining my application dependencies and licenses
  As a non-technical application product owner
  I want license finder to generate an easy-to-understand text report

  Scenario: Generating dependencies multiple times should not lose information
    Given I have an app with license finder
    And my application depends on a gem "descriptive_gem" with:
      | license | version |
      | MIT     | 1.1.1   |
    When I run "license_finder"
    Then I should see the file "dependencies.txt" containing:
      """
      descriptive_gem, 1.1.1, MIT
      """
