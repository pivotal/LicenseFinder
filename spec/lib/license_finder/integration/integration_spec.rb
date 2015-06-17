require "spec_helper"

module LicenseFinder
  describe 'Running the default command from the cli' do
    let(:command_line_options) { [] }
    let(:saved_options) { {} }
    let(:main_class) { CLI::Main }

    it "returns all dependencies when none have been approved" do
      unapproved = capture_stdout do
        main_class.start(command_line_options)
      end
      expect(unapproved).to include('license_finder')
      expect(unapproved).to include('fakefs')
      expect(unapproved).not_to include('abc')
    end

    it "does not return dependencies that have been approved" do
      main_class.start(['approvals','add', 'fakefs'])
      unapproved = capture_stdout do
        main_class.start(command_line_options)
      end
      expect(unapproved).to include('license_finder')
      expect(unapproved).to_not include('fakefs')
      main_class.start(['approvals','remove', 'fakefs'])
    end

    context 'with command line options' do
      let(:command_line_options) { [
          "--decisions_file=whatever.yml",
          "--project_path=../other_project",
          "--gradle_command=do_things",
          "--rebar_command=do_other_things",
          "--rebar_deps_dir=rebar_dir",
          "--save"
      ] }
      let(:logger_options) {
        [
            '--quiet',
            '--debug'
        ]
      }
    end
  end
end