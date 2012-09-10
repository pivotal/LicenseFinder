shared_examples_for "a license matcher" do
  describe "#matches?" do
    context "when a license text template exists" do
      before do
        stub(subject.class).license_text { 'AWESOME "FOO" LICENSE' }
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
end
