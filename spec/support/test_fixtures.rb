module LicenseFinder
  module TestFixtures
    def fixture_path(fixture)
      LicenseFinder::ROOT_PATH.join("..", "..", "spec", "fixtures", fixture)
    end
  end
end
