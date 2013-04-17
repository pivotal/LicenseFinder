require "spec_helper"

module LicenseFinder
  describe CLI do
    def silence_stdout
      orig_stdout = $stdout
      $stdout = File.open(File::NULL, "w")
      yield
    ensure
      $stdout = orig_stdout
    end

    describe "default" do
      it "should check for action items" do
        BundleSyncer.should_receive(:sync!)
        Dependency.stub(:unapproved) { [] }
        silence_stdout do
          described_class.start([])
        end
      end
    end

    describe "#rescan" do
      it "resyncs with Gemfile" do
        BundleSyncer.should_receive(:sync!)
        Dependency.stub(:unapproved) { [] }
        silence_stdout do
          subject.rescan
        end
      end
    end

    describe "#license" do
      it "should update the license on the requested gem" do
        dependency = double :dependency, :name => nil
        dependency.should_receive(:set_license_manually).with("foo")

        Dependency.stub(:first).with(name: "foo_gem").and_return dependency

        silence_stdout do
          subject.license 'foo', 'foo_gem'
        end
      end
    end

    describe "#approve" do
      it "should approve the requested gem" do
        dependency = double('dependency', :name => nil)
        dependency.should_receive(:approve!)

        Dependency.stub(:first).with(name: 'foo').and_return(dependency)

        silence_stdout do
          subject.approve 'foo'
        end
      end
    end
  end
end
