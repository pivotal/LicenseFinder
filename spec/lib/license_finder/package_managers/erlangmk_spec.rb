# frozen_string_literal: true

require "spec_helper"

module LicenseFinder
  describe Erlangmk do
    let(:erlangmk_show_deps) do
<<STDOUT
/erlangmk/project/path/deps/ra 1.0.7 https://hex.pm/packages/ra
/erlangmk/project/path/deps/rabbitmq-cli v3.8.3-rc.1 https://github.com/rabbitmq/rabbitmq-cli
/erlangmk/project/path/deps/rabbitmq-common v3.8.x https://github.com/rabbitmq/rabbitmq-common
STDOUT
    end

    subject(:erlangmk) { Erlangmk.new(project_path: "/erlangmk/project") }

    it_behaves_like "a PackageManager"

    describe "#package_management_command" do
      it "is make with directory and no print" do
        expect(
          erlangmk.package_management_command
        ).to eql(
          "make --directory=/erlangmk/project --no-print-directory"
        )
      end
    end

    describe "#prepare_command" do
      it "resolves deps" do
        expect(
          erlangmk.prepare_command
        ).to eql(
          "make --directory=/erlangmk/project --no-print-directory deps"
        )
      end
    end

    describe "#current_packages" do
      context "when command succeeds" do
        before do
          expect(SharedHelpers::Cmd).to(
            receive(:run)
              .with("make --directory=/erlangmk/project --no-print-directory show-deps")
              .and_return(
                [erlangmk_show_deps, "", cmd_success]
              )
          )
        end

        it "all packages are of type ErlangmkPackages" do
          erlangmk.current_packages.map do |current_package|
            expect(current_package).to be_an(ErlangmkPackage)
          end
        end

        it "returns the expected number of packages" do
          expect(
            erlangmk.current_packages.size
          ).to eql(
            3
          )
        end
      end

      context "when command fails" do
        before do
          expect(SharedHelpers::Cmd).to(
            receive(:run)
              .with("make --directory=/erlangmk/project --no-print-directory show-deps")
              .and_return(
                ["Some error", "", cmd_failure]
              )
          )
        end

        it "raises command error" do
          expect {
            erlangmk.current_packages
          }.to raise_error(
            RuntimeError, /Command 'make --directory=\/erlangmk\/project --no-print-directory show-deps' failed to execute/
          )
        end
      end
    end
  end
end
