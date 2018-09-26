# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Sbt do
    let(:options) { {} }

    subject { Sbt.new(options.merge(project_path: Pathname('/fake/path'))) }

    it_behaves_like 'a PackageManager'

    def license_csv(csv)
      <<-RESP
Category,License,Dependency,Notes
#{csv}
      RESP
    end

    describe '.current_packages' do
      before do
        allow(Dir).to receive(:chdir).with(Pathname('/fake/path')) { |&block| block.call }
        allow(SharedHelpers::Cmd).to receive(:run).with('sbt dumpLicenseReport').and_return(['', '', cmd_success])
      end

      def stub_license_report(deps)
        dependencies = double(:subject_dependency_file, dependencies: [license_csv(deps)])
        expect(SbtDependencyFinder).to receive(:new).and_return(dependencies)
      end

      it 'lists all the current packages' do
        stub_license_report("BSD,BSD 3-Clause (http://www.scala-lang.org/license.html),org.scala-lang # scala-library # 2.11.7
Apache,\"Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)\",commons-io # commons-io # 2.5,")
        expect(subject.current_packages.map { |p| [p.name, p.version] }).to eq [
          ['scala-library', '2.11.7'],
          ['commons-io', '2.5']
        ]
      end
    end
  end
end
