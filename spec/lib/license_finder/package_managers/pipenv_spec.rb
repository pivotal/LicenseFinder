# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Pipenv do
    subject { Pipenv.new(options) }
    let(:options) { { project_path: fixture_path('pipenv-with-lockfile') } }

    it_behaves_like 'a PackageManager'

    describe '#current_packages' do
      def definition_for(item)
        JSON.pretty_generate({
          "info": {
            "author": "",
            "home_page":"",
            "license": item[:license],
            "name": item[:name],
            "summary": "",
            "version": item[:version]
          }
        })
      end

      def url_for(name, version)
        "https://pypi.org/pypi/#{name}/#{version}/json"
      end

      let(:dependencies) do
        [
          { name: 'attrs', version: '19.3.0', license: 'MIT', groups: ['develop'] },
          { name: 'more-itertools', version: '8.0.2', license: 'MIT', groups: ['develop'] },
          { name: 'packaging', version: '20.0', license: 'BSD or Apache License, Version 2.0', groups: ['develop'] },
          { name: 'pluggy', version: '0.13.1', license: 'MIT', groups: ['develop'] },
          { name: 'py', version: '1.8.1', license: 'MIT', groups: ['develop'] },
          { name: 'pyparsing', version: '2.4.6', license: 'MIT', groups: ['develop'] },
          { name: 'pytest', version: '5.3.2', license: 'MIT', groups: ['develop'] },
          { name: 'six', version: '1.13.0', license: 'MIT', groups: ['default', 'develop'] },
          { name: 'wcwidth', version: '0.1.8', license: 'MIT', groups: ['develop'] },
        ]
      end

      before do
        dependencies.each do |item|
          url = url_for(item[:name], item[:version])
          response_body = definition_for(license: item[:license], name: item[:name], version: item[:version])
          stub_request(:get, url).to_return(status: 200, body: response_body)
        end
      end

      it 'fetches each package identified in a Pipfile.lock' do
        actual = subject.current_packages.map do |package|
          [package.name, package.version, package.licenses.map(&:name), package.groups]
        end
        expected = dependencies.map do |package|
          [package[:name], package[:version], [package[:license]], package[:groups]]
        end
        expect(actual).to match_array(expected)
      end

      context "when the development dependencies are ignored" do
        before do
          options[:ignored_groups] = ['develop']
        end

        it 'only returns the default dependencies' do
          actual = subject.current_packages.map do |package|
            [package.name, package.version, package.licenses.map(&:name), package.groups]
          end
          expect(actual).to match_array([['six', '1.13.0', ['MIT'], ['default']]])
        end
      end
    end
  end
end
