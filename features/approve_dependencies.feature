Feature: Approving non-whitelisted Dependencies
  So that I can track the dependencies of my application which my business has approved
  As an application developer using license finder
  I want to be able to manually approve dependencies that have licenses which fall outside of my whitelist

  Scenario: Manually approving a non-whitelisted dependency
    Given I have an app with license finder
    And my app depends on a gem "gpl_gem" licensed with "GPL"
    And I whitelist the "MIT" license

    When I run "license_finder"
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
    When I run "license_finder"
    Then I should not see "gpl_gem" in its output

  Scenario: Manually adding a non-bundled dependency
    Given I have an app with license finder
    When I run "license_finder"
    And I add the following content to "dependencies.yml":
      """
      - name: "my_javascript_library"
        version: "0.0.0"
        license: "GPL"
        approved: false
      """
    Then I should see the following settings for "my_javascript_library":
      """
        version: "0.0.0"
        license: "GPL"
        approved: false
      """
    When I run "license_finder"
    Then I should see "my_javascript_library" in its output
    When I update the settings for "my_javascript_library" with the following content:
      """
        approved: true
      """
    When I run "license_finder"
    Then I should not see "my_javascript_library" in its output
