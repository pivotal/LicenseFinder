Feature: Catch Regressions!

  Scenario: Generating dependencies multiple times should not lose information
    Given I have an app with license finder
    And my application depends on a gem "descriptive_gem" with:
      | license | version |
      | MIT     | 1.1.1   |
    When I run "license_finder"
    When I run "license_finder"
    Then I should see the file "dependencies.txt" containing:
      """
        descriptive_gem, 1.1.1, MIT
      """
