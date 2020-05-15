# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe MavenPackage do
    let(:spec) { { groupId: 'group', artifactId: 'a package', version: '1.1.1' } }
    subject { described_class.new(JSON.parse(spec.to_json)) }

    its(:package_url) { should == 'https://search.maven.org/artifact/group/a+package/1.1.1/jar' }
  end
end
