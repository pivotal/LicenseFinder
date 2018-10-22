# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe XmlReport do
    let(:dep1) do
      result = Package.new('dep_1', '1.0')
      result.decide_on_license(License.find_by_name('MIT'))
      result
    end

    let(:dep2) do
      result = Package.new('dep_2', '2.0')
      result.decide_on_license(License.find_by_name('BSD'))
      result
    end

    let(:expected_report) do
      <<-XML
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<licenseSummary>
  <dependencies>
    <dependency>
      <packageName>dep_1</packageName>
        <version>1.0</version>
        <licenses>
          <license>
            <name>MIT</name>
            <url>http://opensource.org/licenses/mit-license</url>
          </license>
        </licenses>
       </dependency>
       <dependency>
         <packageName>dep_2</packageName>
         <version>2.0</version>
         <licenses>
           <license>
             <name>BSD</name>
             <url>http://en.wikipedia.org/wiki/BSD_licenses#4-clause_license_.28original_.22BSD_License.22.29</url>
          </license>
       </licenses>
    </dependency>
  </dependencies>
</licenseSummary>
      XML
    end

    subject { described_class.new([dep1, dep2], {}) }

    it 'should generate the correct xml report with name, version and license' do
      expect(subject.to_s.gsub(/\s/, '')).to eq(expected_report.gsub(/\s/, ''))
    end
  end
end
