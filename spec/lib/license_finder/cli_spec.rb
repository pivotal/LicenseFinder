require "spec_helper"

module LicenseFinder
  module CLI
    describe Dependencies do
      describe "add" do
        it "adds a dependency" do
          DependencyManager.should_receive(:manually_add).with("MIT", "js_dep", "1.2.3")

          silence_stdout do
            subject.add("MIT", "js_dep", "1.2.3")
          end
        end

        it "does not require a version" do
          DependencyManager.should_receive(:manually_add).with("MIT", "js_dep", nil)

          silence_stdout do
            subject.add("MIT", "js_dep")
          end
        end

        it "has an --approve option to approve the added dependency" do
          DependencyManager.should_receive(:manually_add).with("MIT", "js_dep", "1.2.3")
          DependencyManager.should_receive(:approve!).with("js_dep", "Julian", "We really need this")

          silence_stdout do
            Main.start(["dependencies", "add", "--approve", "--approver", "Julian", "--message", "We really need this", "MIT", "js_dep", "1.2.3"])
          end
        end
      end

      describe "remove" do
        it "removes a dependency" do
          DependencyManager.should_receive(:manually_remove).with("js_dep")
          silence_stdout do
            subject.remove("js_dep")
          end
        end
      end
    end

    describe Whitelist do
      let(:config) { LicenseFinder.config }

      describe "list" do
        it "shows the whitelist of licenses" do
          config.should_receive(:whitelist).and_return([])

          silence_stdout do
            subject.list
          end
        end
      end

      describe "add" do
        it "adds the specified license to the whitelist" do
          config.whitelist.should_receive(:push).with("test")
          config.should_receive(:save)
          Reporter.should_receive(:write_reports)

          silence_stdout do
            subject.add("test")
          end
        end

        it "adds multiple licenses to the whitelist" do
          config.whitelist.should_receive(:push).with("test")
          config.whitelist.should_receive(:push).with("rest")
          config.should_receive(:save)
          Reporter.should_receive(:write_reports)

          silence_stdout do
            subject.add("test", "rest")
          end
        end
      end

      describe "remove" do
        it "removes the specified license from the whitelist" do
          config.should_receive(:save)
          config.whitelist.should_receive(:delete).with("test")
          Reporter.should_receive(:write_reports)

          silence_stdout do

            subject.remove("test")
          end
        end

        it "removes multiple licenses from the whitelist" do
          config.should_receive(:save)
          config.whitelist.should_receive(:delete).with("test")
          config.whitelist.should_receive(:delete).with("rest")
          Reporter.should_receive(:write_reports)

          silence_stdout do
            subject.remove("test", "rest")
          end
        end
      end
    end

    describe ProjectName do
      let(:config) { LicenseFinder.config }

      describe "set" do
        it "sets the project name" do
          config.should_receive(:save)
          config.project_name.should_not eq("new_project_name")
          Reporter.should_receive(:write_reports)

          silence_stdout do
            subject.set("new_project_name")
          end

          config.project_name.should eq("new_project_name")
        end
      end
    end

    describe IgnoredBundlerGroups do
      let(:config) { LicenseFinder.config }

      describe "list" do
        it "shows the ignored groups in the standard output" do
          config.should_receive(:ignore_groups).and_return(['development'])

          expect(capture_stdout { subject.list }).to match /development/
        end
      end

      describe "add" do
        it "adds the specified group to the ignored groups list" do
          config.ignore_groups.should_receive(:push).with("test")
          config.should_receive(:save)
          Reporter.should_receive(:write_reports)

          silence_stdout do
            subject.add("test")
          end
        end
      end

      describe "remove" do
        it "removes the specified group from the ignored groups list" do
          config.ignore_groups.should_receive(:delete).with("test")
          config.should_receive(:save)
          Reporter.should_receive(:write_reports)

          silence_stdout do
            subject.remove("test")
          end
        end
      end
    end

    describe IgnoredDependencies do
      let(:config) { LicenseFinder.config }

      describe "list" do
        context "when there is at least one ignored dependency" do
          it "shows the ignored dependencies" do
            expect(config).to receive(:ignore_dependencies).and_return(['bundler'])
            expect(capture_stdout { subject.list }).to match /bundler/
          end
        end

        context "when there are no ignored dependencies" do
          it "prints '(none)'" do
            expect(config).to receive(:ignore_dependencies).and_return([])
            expect(capture_stdout { subject.list }).to match /\(none\)/
          end
        end
      end

      describe "add" do
        it "adds the specified group to the ignored groups list" do
          config.ignore_dependencies.should_receive(:push).with("test")
          config.should_receive(:save)
          Reporter.should_receive(:write_reports)

          silence_stdout do
            subject.add("test")
          end
        end
      end

      describe "remove" do
        it "removes the specified group from the ignored groups list" do
          config.ignore_dependencies.should_receive(:delete).with("test")
          config.should_receive(:save)
          Reporter.should_receive(:write_reports)

          silence_stdout do
            subject.remove("test")
          end
        end
      end
    end

    describe Main do
      describe "default" do
        it "checks for action items" do
          DependencyManager.should_receive(:sync_with_package_managers)
          Dependency.stub(:unapproved) { [] }
          silence_stdout do
            described_class.start([])
          end
        end
      end

      describe "#rescan" do
        it "resyncs with Gemfile" do
          DependencyManager.should_receive(:sync_with_package_managers)
          Dependency.stub(:unapproved) { [] }

          silence_stdout do
            subject.rescan
          end
        end
      end

      describe "#license" do
        it "updates the license on the requested gem" do
          DependencyManager.should_receive(:license!).with("foo_gem", "foo")

          silence_stdout do
            subject.license 'foo', 'foo_gem'
          end
        end
      end

      describe "#approve" do
        it "approves the requested gem" do
          DependencyManager.should_receive(:approve!).with("foo", nil, nil)

          silence_stdout do
            subject.approve 'foo'
          end
        end

        it "approves multiple gem" do
          DependencyManager.should_receive(:approve!).with("foo", nil, nil)
          DependencyManager.should_receive(:approve!).with("bar", nil, nil)

          silence_stdout do
            subject.approve 'foo', 'bar'
          end
        end

        it "raises a warning if no gem was specified" do
          DependencyManager.should_not_receive(:approve!)

          silence_stdout do
            expect { subject.approve }.to raise_error(ArgumentError)
          end
        end

        it "sets approver and approval message" do
          DependencyManager.should_receive(:approve!).with("foo", "Julian", "We really need this")

          silence_stdout do
            Main.start(["approve", "--approver", "Julian", "--message", "We really need this", "foo"])
          end
        end
      end

      describe "#action_items" do
        it "reports unapproved dependencies" do
          Dependency.stub(:unapproved) { ['one dependency'] }
          TextReport.stub(:new) { double(:report, to_s: "a report!") }
          silence_stdout do
            subject.stub(:say)
            subject.should_receive(:say).with(/dependencies/i, :red)
            expect { subject.action_items }.to raise_error(SystemExit)
          end
        end

        it "reports that all dependencies are approved" do
          Dependency.stub(:unapproved) { [] }
          silence_stdout do
            subject.should_receive(:say).with(/approved/i, :green)
            expect { subject.action_items }.to_not raise_error
          end
        end
      end
    end
  end
end
