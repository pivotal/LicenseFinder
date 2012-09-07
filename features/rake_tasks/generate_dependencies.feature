Feature: rake license:generate_dependencies
  As a user
  I want a rake task the generates a list of all my application's dependencies and their licenses
  So that I can manually approve a dependency with a non-whitelisted license

  Scenario: Manually approve non-whitelisted dependency
    Given I have a rails application with license finder
    And my rails app depends on a gem "gpl_gem" licensed with "GPL"
    And I whitelist the "MIT" license

    When I run "bundle exec rake license:generate_dependencies"

    Then license finder should generate a file "dependencies.yml" that includes the following content:
      """
      - name: "gpl_gem"
        version: "0.0.0"
        license: "GPL"
        approved: false
      """

    When I replace that content with the following content in "dependencies.yml":
      """
      - name: "gpl_gem"
        version: "0.0.0"
        license: "GPL"
        approved: true
      """

    And I run "bundle exec rake license:action_items"

    Then I should not see "gpl_gem" in its output
