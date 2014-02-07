require 'spec_helper'

describe LicenseFinder::License, "SimplifiedBSD" do
  it "should be findable" do
    described_class.find_by_name("SimplifiedBSD").should be
  end
end
