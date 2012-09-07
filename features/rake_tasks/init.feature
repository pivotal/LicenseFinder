Feature: rake license:init
  As a user
  I want a rake task the generates a sample license finder configuration for me
  So that I can easily get started using License Finder

  Scenario: No license finder configuration
    Given I have a rails application with license finder
    When I run "bundle exec rake license:init"
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
