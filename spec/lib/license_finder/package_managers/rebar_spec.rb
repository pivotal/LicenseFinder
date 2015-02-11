require 'spec_helper'

module LicenseFinder
  describe Rebar do
    let(:rebar) { Rebar.new }
    it_behaves_like "a PackageManager"

    output = <<-CMDOUTPUT
      uuid TAG v1.3.2 git://github.com/okeuday/uuid.git
      jiffy TAG 0.9.0 https://github.com/davisp/jiffy.git
    CMDOUTPUT

    describe '.current_packages' do
      it 'lists all the current packages' do
        allow(rebar).to receive(:capture).with(/rebar/).and_return([output, true])

        current_packages = rebar.current_packages

        expect(current_packages.map(&:name)).to eq(["uuid", "jiffy"])
        expect(current_packages.map(&:install_path)).to eq(["deps/uuid", "deps/jiffy"])
      end
      it "fails when command fails" do
        allow(rebar).to receive(:capture).with(/rebar/).and_return('Some error', false).once
        expect { rebar.current_packages }.to raise_error(RuntimeError)
      end

      it "uses custom rebar command, if provided" do
        rebar = Rebar.new(rebar_command: "rebarfoo")

        allow(rebar).to receive(:capture).with(/rebarfoo/).and_return([output, true])

        current_packages = rebar.current_packages

        expect(current_packages.map(&:name)).to eq(["uuid", "jiffy"])
      end

      it "uses custom rebar_deps_dir, if provided" do
        rebar = Rebar.new(rebar_deps_dir: "foo")

        allow(rebar).to receive(:capture).with(/rebar/).and_return([output, true])

        current_packages = rebar.current_packages

        expect(current_packages.map(&:install_path)).to eq(["foo/uuid", "foo/jiffy"])
      end
    end
  end
end
