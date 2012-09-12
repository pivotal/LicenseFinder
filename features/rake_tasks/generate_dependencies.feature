Feature: rake license:generate_dependencies
  As a user
  I want a rake task the generates a list of all my application's dependencies and their licenses
  So that I can manually approve a dependency with a non-whitelisted license

  Scenario: Manually approve non-whitelisted dependency
    Given I have an application setup with rake and license finder
    And my app depends on a gem "gpl_gem" licensed with "GPL"
    And I whitelist the "MIT" license

    When I run "rake license:generate_dependencies"

    Then I should see the following settings for "gpl_gem":
      """
      version: "0.0.0"
      license: "GPL"
      approved: false
      """

    When I update the settings for "gpl_gem" with the following content:
      """
      approved: true
      """

    And I run "rake license:action_items"

    Then I should not see "gpl_gem" in its output

  Scenario: Manually adding a javascript dependency to dependencies.yml
    Given I have an application setup with rake and license finder
    When I run "rake license:generate_dependencies"
    And I add the following content to "dependencies.yml":
      """
      - name: "my_javascript_library"
        version: "0.0.0"
        license: "GPL"
        approved: false
      """
    And I run "rake license:action_items"
    Then I should see "my_javascript_library" in its output

    When I update the settings for "my_javascript_library" with the following content:
      """
      approved: true
      """

    And I run "rake license:action_items"
    Then I should not see "my_javascript_library" in its output

  Scenario: I want to see the group that my dependencies belong to in the dependencies.txt
    Given I have an application setup with rake and license finder
    And my app depends on a gem "mit_gem" licensed with "MIT" in the "production" bundler groups
    When I run "rake license:generate_dependencies"
    Then license finder should generate a file "dependencies.txt" containing:
      """
      mit_gem 0.0.0, MIT, , , production
      """

  Scenario: I have specified multiple groups for my gem
    Given I have an application setup with rake and license finder
    And my app depends on a gem "mit_gem" licensed with "MIT" in the "production, demo, staging" bundler groups
    When I run "rake license:generate_dependencies"
    Then license finder should generate a file "dependencies.txt" containing:
      """
      mit_gem 0.0.0, MIT, , , production, demo, staging
      """

  Scenario: I want to see the gem's summary and description in dependencies.txt
    Given I have an application setup with rake and license finder
    And my application depends on a gem "descriptive_gem" with:
      |license|summary|description|
      |MIT    |summary|description|
    When I run "rake license:generate_dependencies"
    Then license finder should generate a file "dependencies.txt" containing:
      """
      descriptive_gem 0.0.0, MIT, summary, description, default
      """
