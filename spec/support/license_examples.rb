shared_examples_for "a license matcher" do
  describe "#matches?" do
    context "when a license text template exists" do
      before do
        subject.class.stub(:license_text).and_return('AWESOME "FOO" LICENSE')
      end

      it "should return true if the body matches exactly" do
        subject.text = 'AWESOME "FOO" LICENSE'
        should be_matches
      end

      it "should return false if the body does not match at all" do
        subject.text = "hi"
        should_not be_matches
      end

      it "should return true if the body matches disregarding quote and new line differences" do
        subject.text = "AWESOME\n'FOO'\nLICENSE"
        should be_matches
      end
    end
  end

  describe "#license_text" do
    it "should always produce a license text" do
      subject.class.license_text.should_not be_nil, "No license text found for #{subject.class}! Add a license template to lib/data/licenses named '#{subject.class.demodulized_name}.txt'"
    end
  end
end
