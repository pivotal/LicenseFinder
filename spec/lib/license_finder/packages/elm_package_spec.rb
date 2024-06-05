require 'spec_helper'

module LicenseFinder
  describe ElmPackage do
    let(:spec) do
      {
        "type": "package",
        "name": "elm/time",
        "summary": "Work with POSIX times, time zones, years, months, days, hours, seconds, etc.",
        "license": "BSD-3-Clause",
        "version": "1.0.0",
        "exposed-modules": [
          "Time"
        ],
        "elm-version": "0.19.0 <= v < 0.20.0",
        "dependencies": {
          "elm/core": "1.0.0 <= v < 2.0.0"
        },
        "test-dependencies": {}
      }.to_json
    end

    subject do
      ElmPackage.from_elm_json("time", "1.0.0", "elm", JSON.parse(spec))
    end

    its(:authors) { is_expected.to eql ['elm'] }
    its(:name) { is_expected.to eql 'time' }
    its(:licenses) { is_expected.to eql 'BSD-3-Clause' }
    its(:package_url) { is_expected.to eql "https://package.elm-lang.org/packages/elm/time/1.0.0" }
    its(:package_manager) { 'Elm' }
  end
end
