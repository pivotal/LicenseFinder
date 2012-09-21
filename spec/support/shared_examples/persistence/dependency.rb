shared_examples_for "a persistable dependency" do
  let(:klass) { described_class }

  let(:attributes) do
    {
      'name' => "spec_name",
      'version' => "2.1.3",
      'license' => "GPLv2",
      'approved' => false,
      'notes' => 'some notes',
      'homepage' => 'homepage',
      'license_files' => ['/Users/pivotal/foo/lic1', '/Users/pivotal/bar/lic2'],
      'readme_files' => ['/Users/pivotal/foo/Readme1', '/Users/pivotal/bar/Readme2'],
      'source' => "bundle",
      'bundler_groups' => ["test"]
    }
  end

  before do
    klass.delete_all
  end

  describe '.new' do
    subject { klass.new(attributes) }

    context "with known attributes" do
      it "should set the all of the attributes on the instance" do
        attributes.each do |key, value|
          subject.send("#{key}").should equal(value), "expected #{value.inspect} for #{key}, got #{subject.send("#{key}").inspect}"
        end
      end
    end

    context "with unknown attributes" do
      before do
        attributes['foo'] = 'bar'
      end

      it "should raise an exception" do
        expect { subject }.to raise_exception(NoMethodError)
      end
    end
  end

  describe '.unapproved' do
    it "should return all unapproved dependencies" do
      klass.new(name: "unapproved dependency", approved: false).save
      klass.new(name: "approved dependency", approved: true).save

      unapproved = klass.unapproved
      unapproved.count.should == 1
      unapproved.collect(&:approved).any?.should be_false
    end
  end

  describe '.find_by_name' do
    subject { klass.find_by_name gem_name }
    let(:gem_name) { "foo" }

    context "when a gem with the provided name exists" do
      before do
        klass.new(
          'name' => gem_name,
          'version' => '0.0.1'
        ).save
      end

      its(:name) { should == gem_name }
      its(:version) { should == '0.0.1' }
    end

    context "when no gem with the provided name exists" do
      it { should == nil }
    end
  end

  describe '#attributes' do
    it "should return a hash containing the values of all the accessible properties" do
      dep = klass.new(attributes)
      attributes = dep.attributes
      LicenseFinder::DEPENDENCY_ATTRIBUTES.each do |name|
        attributes[name].should == dep.send(name)
      end
    end
  end

  describe '#save' do
    it "should persist all of the dependency's attributes" do
      dep = klass.new(attributes)
      dep.save

      saved_dep = klass.find_by_name(dep.name)

      saved_dep.attributes.should == dep.attributes

      dep.version = "new version"
      dep.save

      saved_dep = klass.find_by_name(dep.name)
      saved_dep.version.should == "new version"
    end
  end

  describe "#update_attributes" do
    it "should update the provided attributes with the provided values" do
      gem = klass.new(attributes)
      updated_attributes = {"version" => "new_version", "license" => "updated_license"}
      gem.update_attributes(updated_attributes)

      saved_gem = klass.find_by_name(gem.name)
      saved_gem.attributes.should == gem.attributes.merge(updated_attributes)
    end
  end

  describe "#destroy" do
    it "should remove itself from the database" do
      foo_dep = klass.new(name: "foo")
      bar_dep = klass.new(name: "bar")
      foo_dep.save
      bar_dep.save

      expect { foo_dep.destroy }.to change { klass.all.count }.by -1

      klass.all.count.should == 1
      klass.all.first.name.should == "bar"
    end
  end
end
