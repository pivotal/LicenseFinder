Feature: License Finder command line executable

  Scenario: Auditing an application with non-whitelisted licenses
    Given I have an app with license finder
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    When I run "license_finder"
    Then it should exit with status code 1
    And I should see "mit_licensed_gem" in its output

  Scenario: Auditing an application with whitelisted licenses
    Given I have an app with license finder
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    And I whitelist the following licenses: "MIT, other"
    When I run "license_finder"
    Then it should exit with status code 0
    And I should see "All gems are approved for use" in its output

  Scenario: Manually approving a non-whitelisted dependency
    Given I have an application setup with rake and license finder
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
    Given I have an application setup with rake and license finder
    When I run "license_finder"
    And I add the following content to "dependencies.yml":
      """
      - name: "my_javascript_library"
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
