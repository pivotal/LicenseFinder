# frozen_string_literal: true

require "spec_helper"

module LicenseFinder
  describe Erlangmk do
    let(:project_path) { spy("dir_with_erlangmk") }

    let(:erlangmk_show_deps) do
<<STDOUT
/erlangmk/project/path/deps/ra 1.0.5 https://hex.pm/packages/ra
/erlangmk/project/path/deps/rabbitmq-cli v3.8.3-beta.2 https://github.com/rabbitmq/rabbitmq-cli
/erlangmk/project/path/deps/rabbitmq-common master https://github.com/rabbitmq/rabbitmq-common
STDOUT
    end

    subject(:erlangmk) { Erlangmk.new(project_path: project_path) }

    it_behaves_like "a PackageManager"

    describe ".package_management_command" do
      it "is make" do
        expect(Erlangmk.package_management_command).to eql("make")
      end
    end

    describe "#prepare_command" do
      it "resolves deps" do
        expect(erlangmk.prepare_command).to eql("make deps")
      end
    end

    describe "#current_packages" do
      before do
        allow(Dir).to(
          receive(:chdir)
            .with(project_path) { |&block| block.call }
        )
      end

      context "when command succeeds" do
        before do
          expect(SharedHelpers::Cmd).to(
            receive(:run)
              .with("make show-deps")
              .and_return(
                [erlangmk_show_deps, "", cmd_success]
              )
          )
        end

        it "returns some packages" do
          expect(erlangmk.current_packages.size).to be > 1
        end

        it "returns all ErlangmkPackages" do
          erlangmk.current_packages.map do |current_package|
            expect(current_package).to be_an(ErlangmkPackage)
          end
        end
      end

      context "when command fails" do
        it "raises command error"
      end
    end

  end
end
