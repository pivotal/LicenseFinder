require "spec_helper"

module LicenseFinder
  module CLI
    context do
      let!(:dependency_manager) { DependencyManager.new }

      before do
        allow(Decisions).to receive(:saved!) { Decisions.new }
        allow(DependencyManager).to receive(:new) { dependency_manager }
      end

      describe Dependencies do
        describe "add" do
          it "adds a dependency" do
            expect(dependency_manager).to receive(:manually_add).with("MIT", "js_dep", "1.2.3")

            silence_stdout do
              subject.add("MIT", "js_dep", "1.2.3")
            end
          end

          it "does not require a version" do
            expect(dependency_manager).to receive(:manually_add).with("MIT", "js_dep", nil)

            silence_stdout do
              subject.add("MIT", "js_dep")
            end
          end

          it "has an --approve option to approve the added dependency" do
            expect(dependency_manager).to receive(:manually_add).with("MIT", "js_dep", "1.2.3")
            expect(dependency_manager).to receive(:approve!).with("js_dep", "Julian", "We really need this")

            silence_stdout do
              Main.start(["dependencies", "add", "--approve", "--approver", "Julian", "--message", "We really need this", "MIT", "js_dep", "1.2.3"])
            end
          end
        end

        describe "remove" do
          it "removes a dependency" do
            expect(dependency_manager).to receive(:manually_remove).with("js_dep")
            silence_stdout do
              subject.remove("js_dep")
            end
          end
        end

        describe "list" do
          it "lists manually added dependencies" do
            allow(Decisions).to receive(:saved!) do
              Decisions.new.add_package("custom", nil)
            end
            expect(capture_stdout { subject.list }).to match /custom/
          end
        end
      end

      describe Whitelist do
        describe "list" do
          it "shows the whitelist of licenses" do
            allow(Decisions).to receive(:saved!) do
              Decisions.new.whitelist("MIT")
            end

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
        let(:config) { LicenseFinder.config }

        describe "set" do
          it "sets the project name" do
            expect(config).to receive(:save)
            expect(config.project_name).not_to eq("new_project_name")

            silence_stdout do
              subject.set("new_project_name")
            end

            expect(config.project_name).to eq("new_project_name")
          end
        end
      end

      describe IgnoredBundlerGroups do
        describe "list" do
          it "shows the ignored groups in the standard output" do
            allow(Decisions).to receive(:saved!) do
              Decisions.new.ignore_group("development")
            end

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
              allow(Decisions).to receive(:saved!) do
                Decisions.new.ignore("bundler")
              end
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
            allow(Decisions).to receive(:saved!) do
              Decisions.new.add_package("a dependency", nil)
            end

            silence_stdout do
              expect { described_class.start([]) }.to raise_error(SystemExit)
            end
          end
        end

        describe "#license" do
          it "updates the license on the requested gem" do
            expect(dependency_manager).to receive(:license!).with("foo_gem", "foo")
            silence_stdout do
              subject.license 'foo', 'foo_gem'
            end
          end
        end

        describe "#approve" do
          it "approves the requested gem" do
            expect(dependency_manager).to receive(:approve!).with("foo", nil, nil)

            silence_stdout do
              subject.approve 'foo'
            end
          end

          it "approves multiple gem" do
            expect(dependency_manager).to receive(:approve!).with("foo", nil, nil)
            expect(dependency_manager).to receive(:approve!).with("bar", nil, nil)

            silence_stdout do
              subject.approve 'foo', 'bar'
            end
          end

          it "raises a warning if no gem was specified" do
            expect(dependency_manager).not_to receive(:approve!)

            silence_stdout do
              expect { subject.approve }.to raise_error(ArgumentError)
            end
          end

          it "sets approver and approval message" do
            expect(dependency_manager).to receive(:approve!).with("foo", "Julian", "We really need this")

            silence_stdout do
              Main.start(["approve", "--approver", "Julian", "--message", "We really need this", "foo"])
            end
          end
        end

        describe "#report" do
          before do
            allow(dependency_manager).to receive(:current_packages) { [ManualPackage.new('one dependency')] }
          end

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
          it "reports unapproved dependencies" do
            allow(dependency_manager).to receive(:current_packages) { [ManualPackage.new('one dependency')] }
            allow(TextReport).to receive(:new) { double(:report, to_s: "a report!") }
            silence_stdout do
              allow(subject).to receive(:say)
              expect(subject).to receive(:say).with(/dependencies/i, :red)
              expect { subject.action_items }.to raise_error(SystemExit)
            end
          end

          it "reports that all dependencies are approved" do
            allow(dependency_manager).to receive(:current_packages) { [] }
            silence_stdout do
              expect(subject).to receive(:say).with(/approved/i, :green)
              expect { subject.action_items }.to_not raise_error
            end
          end
        end
      end
    end
  end
end
