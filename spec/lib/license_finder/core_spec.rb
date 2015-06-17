require "spec_helper"

module LicenseFinder
  describe Core do
    let(:options) { {} }
    let(:license_finder) { described_class.new(options) }
    let(:logger) { Logger.new(options[:logger]) }
    let(:pathname) { Pathname.pwd + Pathname.new(options[:project_path]) }

    before do
      allow(Logger).to receive(:new).and_return(logger)
      allow(Pathname).to receive(:new).and_return(pathname)
    end

    describe "#unapproved" do
      let(:options) {
        {
          logger: {},
          project_path: 'other_directory',
          gradle_command: 'just_do_it',
          rebar_command: 'do_it',
          rebar_deps_dir: 'nowhere/deps'
        }
      }
      let(:package_options) {
        {
          logger: logger,
          project_path: pathname,
          ignore_groups: Set.new,
          gradle_command: options[:gradle_command],
          rebar_command: options[:rebar_command],
          rebar_deps_dir: options[:project_path] + "/" + options[:rebar_deps_dir]
        }
      }

      it "delegates to the decision_applier" do
        decision_applier =  double(:decision_applier)
        allow(license_finder).to receive(:decision_applier).and_return(decision_applier)
        expect(decision_applier).to receive(:unapproved)
        license_finder.unapproved
      end

      it "passes through options when fetching current packages" do
        expect(PackageManager).to receive(:current_packages).with(package_options).and_return([])
        license_finder.unapproved
      end
    end
  end
end
