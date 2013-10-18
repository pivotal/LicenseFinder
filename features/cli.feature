Feature: License Finder command line executable
  So that I can report and manage my application's dependencies and licenses to my business
  As an application developer
  I want a command-line interface

  Scenario: Running without a configuration file
    Given I have an app with license finder that has no config directory
    When I run license_finder
    Then it creates a config directory with the license_finder config

  Scenario: Auditing an application with non-whitelisted licenses
    Given I have an app with license finder that depends on a MIT licensed gem
    When I run license_finder
    Then it should exit with status code 1
    And should list my MIT gem in the output

  Scenario: Auditing an application with whitelisted licenses
    Given I have an app with license finder that depends on a MIT licensed gem
    When I whitelist MIT and 'other' and New BSD and Apache 2.0 and Ruby licenses
    Then it should exit with status code 0
    And I should see all gems approved for use

  Scenario: Keep manually set license dependencies
    Given I have a project that depends on mime-types with a manual license type
    When I run license_finder
    Then the mime-types license remains set with my manual license type

  Scenario: Viewing help for license_finder subcommand
    Given I have an app with license finder
    When I run license_finder help on a specific command
    Then I should see the correct subcommand usage instructions

  Scenario: Viewing help for license_finder default
    Given I have an app with license finder
    When I run license_finder help
    Then I should the correct default usage instructions
