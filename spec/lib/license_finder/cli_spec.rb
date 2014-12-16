require "spec_helper"

module LicenseFinder
  module CLI
    context do
      let!(:dependency_manager) do
        DependencyManager.new(
          decisions: decisions,
          packages: packages
        )
      end
      let(:packages) { [] }
      let!(:decisions) { Decisions.new }

      before do
        allow(Decisions).to receive(:saved!) { decisions }
        allow(DependencyManager).to receive(:new) { dependency_manager }
      end

      describe Dependencies do
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

      describe Whitelist do
        describe "list" do
          it "shows the whitelist of licenses" do
            decisions.whitelist("MIT")

            expect(capture_stdout { subject.list }).to match /MIT/
          end
        end

        describe "add" do
          it "adds the specified license to the whitelist" do
            silence_stdout do
              subject.add("test")
            end
            expect(subject.decisions.whitelisted).to eq [License.find_by_name("test")].to_set
          end

          it "adds multiple licenses to the whitelist" do
            silence_stdout do
              subject.add("test", "rest")
            end
            expect(subject.decisions.whitelisted).to eq [
              License.find_by_name("test"),
              License.find_by_name("rest")
            ].to_set
          end
        end

        describe "remove" do
          it "removes the specified license from the whitelist" do
            silence_stdout do
              subject.add("test")
              subject.remove("test")
            end
            expect(subject.decisions.whitelisted).to be_empty
          end

          it "removes multiple licenses from the whitelist" do
            silence_stdout do
              subject.add("test", "rest")
              subject.remove("test", "rest")
            end
            expect(subject.decisions.whitelisted).to be_empty
          end
        end
      end

      describe ProjectName do
        describe "show" do
          it "shows the configured project name" do
            decisions.name_project("test")

            expect(capture_stdout { subject.show }).to match /test/
          end
        end

        describe "add" do
          it "sets the project name" do
            silence_stdout do
              subject.add("test")
            end
            expect(subject.decisions.project_name).to eq "test"
          end
        end

        describe "remove" do
          it "removes the project name" do
            silence_stdout do
              subject.add("test")
              subject.remove
            end
            expect(subject.decisions.project_name).to be_nil
          end
        end
      end

      describe IgnoredGroups do
        describe "list" do
          it "shows the ignored groups in the standard output" do
            decisions.ignore_group("development")

            expect(capture_stdout { subject.list }).to match /development/
          end
        end

        describe "add" do
          it "adds the specified group to the ignored groups list" do
            silence_stdout do
              subject.add("test")
            end
            expect(subject.decisions.ignored_groups).to eq ["test"].to_set
          end
        end

        describe "remove" do
          it "removes the specified group from the ignored groups list" do
            silence_stdout do
              subject.add("test")
              subject.remove("test")
            end
            expect(subject.decisions.ignored_groups).to be_empty
          end
        end
      end

      describe IgnoredDependencies do
        describe "list" do
          context "when there is at least one ignored dependency" do
            it "shows the ignored dependencies" do
              decisions.ignore("bundler")
              expect(capture_stdout { subject.list }).to match /bundler/
            end
          end

          context "when there are no ignored dependencies" do
            it "prints '(none)'" do
              expect(capture_stdout { subject.list }).to match /\(none\)/
            end
          end
        end

        describe "add" do
          it "adds the specified group to the ignored groups list" do
            silence_stdout do
              subject.add("test")
            end
            expect(subject.decisions.ignored).to eq ["test"].to_set
          end
        end

        describe "remove" do
          it "removes the specified group from the ignored groups list" do
            silence_stdout do
              subject.add("test")
              subject.remove("test")
            end
            expect(subject.decisions.ignored).to be_empty
          end
        end
      end

      describe Main do
        describe "default" do
          it "checks for action items" do
            decisions.add_package("a dependency", nil)

            silence_stdout do
              expect { described_class.start(["--quiet"]) }.to raise_error(SystemExit)
            end
          end
        end

        describe "#license" do
          it "updates the license on the requested gem" do
            silence_stdout do
              subject.license 'foo', 'foo_gem'
            end
            expect(subject.decisions.license_of("foo_gem").name).to eq "foo"
          end
        end

        describe "#approve" do
          it "approves the requested gem" do
            silence_stdout do
              subject.approve 'foo'
            end
            expect(subject.decisions).to be_approved "foo"
          end

          it "approves multiple gem" do
            silence_stdout do
              subject.approve 'foo', 'bar'
            end
            expect(subject.decisions).to be_approved "foo"
            expect(subject.decisions).to be_approved "bar"
          end

          it "raises a warning if no gem was specified" do
            silence_stdout do
              expect { subject.approve }.to raise_error(ArgumentError)
            end
          end

          it "sets approver and approval message" do
            expect(decisions).to receive(:approve).with("foo", hash_including(who: "Julian", why:  "We really need this"))

            silence_stdout do
              Main.start(["approve", "--who", "Julian", "--why", "We really need this", "foo"])
            end
          end
        end

        describe "#report" do
          let(:packages) { [ManualPackage.new('one dependency')] }

          it "reports acknowleged dependencies" do
            result = capture_stdout do
              Main.start(["report"])
            end
            expect(result).to eq "\"one dependency\", , other\n"
          end

          it "will output a specific format" do
            result = capture_stdout do
              Main.start(["report", "--format", "detailed_text"])
            end

            expect(result).to eq "one dependency,,other,\"\",\"\"\n"
          end
        end

        describe "#action_items" do
          context "with unapproved dependencies" do
            let(:packages) { [ManualPackage.new('one dependency')] }

            it "reports unapproved dependencies" do
              result = capture_stdout do
                expect do
                  Main.start(["action_items", "--quiet"])
                end.to raise_error(SystemExit)
              end
              expect(result).to match /dependencies/i
              expect(result).to match /one dependency/
            end
          end

          it "reports that all dependencies are approved" do
            result = capture_stdout do
              expect do
                Main.start(["action_items", "--quiet"])
              end.not_to raise_error
            end
            expect(result).to match /approved/i
          end
        end
      end
    end
  end
end
