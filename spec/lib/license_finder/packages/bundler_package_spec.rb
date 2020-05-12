# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe BundlerPackage do
    let(:spec) do
      Struct
        .new(:name, :version, :authors, :dependencies, :summary, :description, :homepage, :licenses, :full_gem_path)
        .new('a package', '1.1.1', [], [], '', '', '', [], '')
    end
    subject { described_class.new(spec, nil) }

    its(:package_url) { should == 'https://rubygems.org/gems/a%20package/versions/1.1.1' }
  end
end
