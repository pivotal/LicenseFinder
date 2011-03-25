require 'license_finder'
require 'rails'
module LicenseFinder
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/license_finder.rake"
    end
  end
end