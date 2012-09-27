shared_examples_for "a persistable configuration" do
  let(:klass) { described_class }

  let(:attributes) do
    {
      "whitelist" => ["FooLicense", "BarLicense"],
      "ignore_groups" => [:test, :development]
    }
  end

  describe '.new' do
    subject { klass.new(attributes) }

    context "with known attributes" do
      it "should set the all of the attributes on the instance" do
        attributes.each do |key, value|
          subject.send("#{key}").should == value
        end
      end
    end
  end

  describe "#whitelist" do
    it "should default to an empty array" do
      klass.new.whitelist.should == []
    end
  end
end
