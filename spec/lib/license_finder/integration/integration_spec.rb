require "spec_helper"

module LicenseFinder
  describe 'Running the default command from the cli' do
    let(:command_line_options) { [] }
    let(:saved_options) { {} }
    let(:main_class) { CLI::Main }

    it "returns all dependencies when none have been approved" do
      unapproved = capture_stdout do
        expect{ main_class.start(command_line_options) }.to raise_error(SystemExit)
      end
      expect(unapproved).to include('license_finder')
      expect(unapproved).to include('fakefs')
      expect(unapproved).not_to include('abc')
    end

    it "does not return dependencies that have been approved" do
      silence_stdout{ main_class.start(['approvals','add', 'fakefs']) }
      unapproved = capture_stdout do
        expect{ main_class.start(command_line_options) }.to raise_error(SystemExit)
      end
      expect(unapproved).to include('license_finder')
      expect(unapproved).to_not include('fakefs')
      silence_stdout{ main_class.start(['approvals','remove', 'fakefs']) }
    end

    context 'with command line options' do # duplicate of set_project_path_spec

      describe "running the default command against another directory" do
        let(:command_line_options) { ["--project_path=spec/dummy_app"] }

        it "only reports dependencies for the project in the specified directory" do
          unapproved = capture_stdout do
            expect{ main_class.start(command_line_options) }.to raise_error(SystemExit)
          end
          expect(unapproved).to include('httparty')
          expect(unapproved).not_to include('license_finder')
        end
      end
    end
  end
end