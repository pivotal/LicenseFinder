# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe XmlReport do
    it 'should generate the correct xml report with name, version and license' do
      dep = Package.new('dep_1', '1.0', {spec_licenses: 'MIT'})
      dep2 = Package.new('dep_2', '2.0', {spec_licenses: 'BSD'})
      subject = described_class.new([dep, dep2], {})
      expected_report = <<-XML
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<licenseSummary>
   <dependencies>
           <dependency>
         <packageName>dep_1</packageName>
         <version>1.0</version>
         <licenses>
                       <license>
               <name>unknown</name>
               <url></url>
             </license>
                   </licenses>
       </dependency>
           <dependency>
         <packageName>dep_2</packageName>
         <version>2.0</version>
         <licenses>
                       <license>
               <name>unknown</name>
               <url></url>
             </license>
                   </licenses>
       </dependency>
       </dependencies>
</licenseSummary>
      XML
      expect(subject.to_s.gsub(/\s/,'')).to eq(expected_report.gsub('/\s/,'))
    end
  end
end
