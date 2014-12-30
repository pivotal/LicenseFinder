require "spec_helper"

module LicenseFinder
  module CLI
    describe Licenses do
      let(:decisions) { Decisions.new }

      before do
        allow(Decisions).to receive(:saved!) { decisions }
      end

      describe "add" do
        it "updates the license on the requested gem" do
          silence_stdout do
            subject.add 'foo_gem', 'foo_license'
          end
          expect(subject.decisions.license_of("foo_gem").name).to eq "foo_license"
        end
      end

      describe "remove" do
        it "removes the license from the dependency" do
          silence_stdout do
            subject.add("test", "lic")
            subject.remove("test")
          end
          expect(subject.decisions.license_of("test")).to be_nil
        end

        it "is cumulative" do
          silence_stdout do
            subject.add("test", "lic")
            subject.remove("test")
            subject.add("test", "lic")
          end
          expect(subject.decisions.license_of("test").name).to eq "lic"
        end
      end
    end
  end
end
