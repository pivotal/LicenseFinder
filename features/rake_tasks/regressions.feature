Feature: Catch Regressions!

  Scenario Outline: Generating dependencies multiple times should not lose information
    Given I have an application setup with rake and license finder
    And my application depends on a gem "descriptive_gem" with:
    | license | summary | description |
    | MIT     | summary | description |
    When I run "<command>"
    And I run "<command>"
    Then license finder should generate a file "dependencies.txt" containing:
      """
      descriptive_gem, 0.0.0, MIT
      """

    Examples:
    | command                            |
    | rake license:generate_dependencies |
    | rake license:action_items          |
