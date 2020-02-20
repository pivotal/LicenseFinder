# frozen_string_literal: true

require 'json'
require 'spec_helper'
require 'active_support/core_ext/hash/keys'

module LicenseFinder
  describe OsstpReport do
    it 'understands many columns' do
      dep = Package.new('gem_a', '1.0', authors: 'the authors',
                                        description: 'A description', summary: 'A summary',
                                        homepage: 'http://homepage.example.com')
      dep.decide_on_license(License.find_by_name('MIT'))
      dep.decide_on_license(License.find_by_name('GPL'))
      dep.permitted!
      subject = described_class.new([dep], columns: %w[name version authors licenses approved summary description homepage])
      expected = {
        'unknown:gem_a:1.0': {
          license: 'GPL,MIT',
          name: 'gem_a',
          url: 'http://homepage.example.com',
          repository: 'unknown',
          version: '1.0'
        }
      }.deep_stringify_keys.to_yaml.gsub("---\n", '')

      expect(subject.to_s).to eq(expected)
    end
  end
end
