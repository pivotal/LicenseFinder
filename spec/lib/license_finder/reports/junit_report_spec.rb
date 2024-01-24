# frozen_string_literal: true

require 'spec_helper'
module LicenseFinder
  describe JunitReport do
    let(:dep1) do
      result = Package.new(
        'dep_1',
        '1.0',
        {
          summary: 'Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...',
          description: "Lorem ipsum dolor sit amet, elit. Nunc iaculis\nsed sapien nec suscipit.",
          homepage: 'http://example.com/packages/dep_1',
          package_url: 'http://example.com/packages/dep_1',
          children: ['child_1']
        }
      )
      result.decide_on_license(License.find_by_name('MIT'))
      result
    end

    let(:dep2) do
      result = Package.new('dep_2', '2.0')
      result.decide_on_license(License.find_by_name('BSD'))
      result
    end
    let(:dep3) do
      result = Package.new('dep_3', '3.0')
      result.decide_on_license(License.find_by_name('GPL'))
      result.approved_manually!(Decisions::TXN.new('the-approver', 'the-approval-note', Time.now.utc))
      result
    end

    let(:expected_report) do
      <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<testsuites failures="2" name="" tests="3">
  <testsuite failures="1" id="0" name="dep_1" package="Gemfile.lock" skipped="0" tests="1" timestamp="2020-10-07T23:08:58:874569">
    <testcase classname="MIT" name="dep_1">
      <failure message="Unapproved license in 'dep_1' 1.0">
Name: dep_1
Version: 1.0
Licence:
- MIT: http://opensource.org/licenses/mit-license
URL: http://example.com/packages/dep_1
Homepage: http://example.com/packages/dep_1
Summary: Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...
Description: Lorem ipsum dolor sit amet, elit. Nunc iaculis
sed sapien nec suscipit.
Requirements:
- child_1
      </failure>
      <system-out>
stdout
      </system-out>
      <system-err>
stderr
      </system-err>
    </testcase>
  </testsuite>
  <testsuite failures="1" id="1" name="dep_2" package="Gemfile.lock" skipped="0" tests="1" timestamp="2020-10-07T23:08:58:874569">
    <testcase classname="BSD" name="dep_2">
      <failure message="Unapproved license in 'dep_2' 2.0">
Name: dep_2
Version: 2.0
Licence:
- BSD: https://directory.fsf.org/wiki/License:BSD-4-Clause
URL:
Homepage:
Summary:
Description:
      </failure>
      <system-out>
stdout
      </system-out>
      <system-err>
stderr
      </system-err>
    </testcase>
  </testsuite>
  <testsuite failures="0" id="2" name="dep_3" package="Gemfile.lock" skipped="0" tests="1" timestamp="2020-10-07T23:08:58:874569">
    <testcase classname="GPL" name="dep_3" />
  </testsuite>
</testsuites>
      XML
    end

    subject { described_class.new([dep1, dep2, dep3], {}) }

    it 'should generate the correct xml report with name, version and license' do
      Time.stub(:now).and_return(Time.mktime(2020, 10, 7, 23, 8, 58.874569))
      expect(subject.to_s.gsub(/\s+\n/, "\n")).to eq(expected_report.gsub(/\s+\n/, "\n"))
    end

    it 'should generate a valid junit xml file' do
      schema = Nokogiri::XML::Schema(fixture_from('jenkins-junit.xsd'))
      document = Nokogiri::XML(subject.to_s)
      expect(schema.validate(document)).to eq([])
    end
  end
end
