# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Pipenv do
    let(:root) { fixture_path('pipenv-with-lockfile') }
    let(:pipenv) { Pipenv.new(project_path: root) }
    it_behaves_like 'a PackageManager'

    describe '#current_packages' do
      let(:response_body) do
        <<~RAW
{
  "info": {
    "author": "Benjamin Peterson",
    "classifiers": [
      "Development Status :: 5 - Production/Stable",
      "Intended Audience :: Developers",
      "License :: OSI Approved :: MIT License",
      "Programming Language :: Python :: 2",
      "Programming Language :: Python :: 3",
      "Topic :: Software Development :: Libraries",
      "Topic :: Utilities"
    ],
    "home_page": "https://github.com/benjaminp/six",
    "license": "MIT",
    "name": "six",
    "summary": "Python 2 and 3 compatibility utilities",
    "version": "1.13.0"
  }
}
        RAW
      end

      before do
        stub_request(:get, "https://pypi.org/pypi/six/1.13.0/json")
          .to_return(status: 200, body: response_body)
      end

      it 'fetches data for pipenv' do
        results = pipenv.current_packages.map do |package|
          [package.name, package.version, package.licenses.map { |x| x.send(:short_name) }]
        end
        expect(results).to match_array([ ['six', '1.13.0', ['MIT']] ])
      end
    end
  end
end
