require 'spec_helper'

module LicenseFinder
  describe BundlerPackage do
    subject { described_class.new(gemspec, bundler_dependency) }

    let(:gemspec) do
      Gem::Specification.new do |s|
        s.name = 'spec_name'
        s.version = '2.1.3'
        s.summary = 'summary'
        s.description = 'description'
        s.homepage = 'homepage'
        s.licenses = ['MIT', 'GPL']

        s.add_dependency 'foo'
      end
    end

    let(:bundler_dependency) { double(:dependency, groups: %i[staging assets]) }

    its(:name) { should == 'spec_name' }
    its(:version) { should == '2.1.3' }
    its(:summary) { should == "summary" }
    its(:description) { should == "description" }
    its(:homepage) { should == "homepage" }
    its(:groups) { should == %w[staging assets] }
    its(:children) { should == ['foo'] }
    its(:license_names_from_spec) { should eq ['MIT', 'GPL'] }
    its(:install_path) { should =~ /spec_name-2\.1\.3\z/ }
  end
end
