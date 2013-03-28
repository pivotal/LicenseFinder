Feature: License Finder rake task
  So that I can break my build suite if someone adds a dependency to the application with a non-whitelisted license
  As an application developer
  I want a rake task that exit's with a non-zero exit status if there are any action items

  Scenario: Running without a configuration file
    Given I have an app with rake and license finder
    And my app does not have a "config" directory
    When I run "rake license_finder"
    Then I should see a "config" directory
    And I should see the file "config/license_finder.yml" with the following content:
      """
      ---
      whitelist:
      #- MIT
      #- Apache 2.0
      ignore_groups:
      #- test
      #- development
      dependencies_file_dir: './doc/'

      """

  Scenario: Auditing an application with non-whitelisted licenses
    Given I have an app with rake and license finder
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    When I run "rake license_finder"
    Then it should exit with status code 1
    And I should see "mit_licensed_gem" in its output

  Scenario: Auditing an application with whitelisted licenses
    Given I have an app with rake and license finder
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    And I whitelist the following licenses: "MIT, other"
    When I run "rake license_finder"
    Then it should exit with status code 0
    And I should see "All gems are approved for use" in its output
