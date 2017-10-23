require 'spec_helper'

module LicenseFinder
  describe Rebar do
    subject { Rebar.new(project_path: Pathname('/fake/path')) }

    it_behaves_like "a PackageManager"

    output = <<-CMDOUTPUT
== Sample comment
uuid TAG v1.3.2 git://github.com/okeuday/uuid.git
jiffy TAG 0.9.0 https://github.com/davisp/jiffy.git
    CMDOUTPUT

    describe '.current_packages' do
      before do
        allow(Dir).to receive(:chdir).with(Pathname('/fake/path')) { |&block| block.call }
      end

      it 'lists all the current packages' do
        allow(subject).to receive(:capture).with('rebar list-deps').and_return([output, '', 0])

        current_packages = subject.current_packages
        expect(current_packages.map(&:name)).to eq(["uuid", "jiffy"])
        expect(current_packages.map(&:install_path)).to eq([Pathname("deps/uuid"), Pathname("deps/jiffy")])
      end

      it "fails when command fails" do
        allow(subject).to receive(:capture).with(/rebar/).and_return(['Some error', '', 1]).once
        expect { subject.current_packages }.to raise_error(RuntimeError)
      end

      it "uses custom rebar command, if provided" do
        rebar = Rebar.new(rebar_command: "rebarfoo", project_path: Pathname('/fake/path'))
        allow(rebar).to receive(:capture).with(/rebarfoo/).and_return([output, '', 0])

        current_packages = rebar.current_packages
        expect(current_packages.map(&:name)).to eq(["uuid", "jiffy"])
      end

      it "uses custom rebar_deps_dir, if provided" do
        rebar = Rebar.new(rebar_deps_dir: "foo", project_path: Pathname('/fake/path'))
        allow(rebar).to receive(:capture).with(/rebar/).and_return([output, '', 0])

        current_packages = rebar.current_packages
        expect(current_packages.map(&:install_path)).to eq([Pathname("foo/uuid"), Pathname("foo/jiffy")])
      end
    end
  end
end
