Feature: rake license:init
  As a user
  I want a rake task the generates a sample license finder configuration for me
  So that I can easily get started using License Finder

  Scenario: No license finder configuration
    Given I have a rails application with license finder
    When I run "rake license:init"
    Then license finder should generate a file "config/license_finder.yml" with the following content:
      """
        ---
        whitelist:
        #- MIT
        #- Apache 2.0
        ignore_groups:
        #- test
        #- development
        dependencies_file_dir: './'
      """

  Scenario: The project including LicenseFinder does not already have a config directory
    Given I have an application with license finder
    And my application's rake file requires license finder
    And my application does not have a config directory
    When I run "rake license:init"
    Then the config directory should exist
