require "spec_helper"

module LicenseFinder
  module CLI
    describe Blacklist do
      let(:decisions) { Decisions.new }

      before do
        allow(Decisions).to receive(:saved!) { decisions }
      end

      describe "list" do
        it "shows the blacklist of licenses" do
          decisions.blacklist("MIT")

          expect(capture_stdout { subject.list }).to match /MIT/
        end
      end

      describe "add" do
        it "adds the specified license to the blacklist" do
          silence_stdout do
            subject.add("test")
          end
          expect(subject.decisions.blacklisted).to eq [License.find_by_name("test")].to_set
        end

        it "adds multiple licenses to the blacklist" do
          silence_stdout do
            subject.add("test", "rest")
          end
          expect(subject.decisions.blacklisted).to eq [
            License.find_by_name("test"),
            License.find_by_name("rest")
          ].to_set
        end
      end

      describe "remove" do
        it "removes the specified license from the blacklist" do
          silence_stdout do
            subject.add("test")
            subject.remove("test")
          end
          expect(subject.decisions.blacklisted).to be_empty
        end

        it "removes multiple licenses from the blacklist" do
          silence_stdout do
            subject.add("test", "rest")
            subject.remove("test", "rest")
          end
          expect(subject.decisions.blacklisted).to be_empty
        end
      end
    end
  end
end
