# frozen_string_literal: true

module LicenseFinder
  module TestFixtures
    def fixture_path(fixture)
      LicenseFinder::ROOT_PATH.join('..', '..', 'spec', 'fixtures', fixture)
    end

    def fixture_from(filename)
      filepath = LicenseFinder::ROOT_PATH.join('..', '..', 'spec', 'fixtures', 'config', filename)
      File.open(filepath, &:read)
    end
  end
end
