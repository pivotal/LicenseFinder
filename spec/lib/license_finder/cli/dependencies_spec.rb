require "spec_helper"

module LicenseFinder
  module CLI
    describe Dependencies do
      let(:decisions) { Decisions.new }

      before do
        allow(Decisions).to receive(:saved!) { decisions }
      end

      describe "add" do
        it "adds a dependency" do
          silence_stdout do
            subject.add("MIT", "js_dep", "1.2.3")
          end

          expect(subject.decisions.packages.size).to eq 1
          package = subject.decisions.packages.first
          expect(package.name).to eq "js_dep"
          expect(package.version).to eq "1.2.3"
          expect(subject.decisions.license_of("js_dep")).to eq License.find_by_name("MIT")
        end

        it "does not require a version" do
          silence_stdout do
            subject.add("MIT", "js_dep")
          end
          package = subject.decisions.packages.first
          expect(package.version).to be_nil
        end

        it "has an --approve option to approve the added dependency" do
          expect(decisions).to receive(:approve).with("js_dep", hash_including(who: "Julian", why:  "We really need this"))
          silence_stdout do
            Main.start(["dependencies", "add", "--approve", "--who", "Julian", "--why", "We really need this", "MIT", "js_dep", "1.2.3"])
          end
        end
      end

      describe "remove" do
        it "removes a dependency" do
          silence_stdout do
            subject.add("MIT", "js_dep")
            subject.remove("js_dep")
          end
          expect(subject.decisions.packages).to be_empty
        end
      end

      describe "list" do
        it "lists manually added dependencies" do
          decisions.add_package("custom", nil)
          expect(capture_stdout { subject.list }).to match /custom/
        end
      end
    end
  end
end
