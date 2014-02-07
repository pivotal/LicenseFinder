require 'spec_helper'

describe LicenseFinder::License, "ISC" do
  it "should be findable" do
    described_class.find_by_name("ISC").should be
  end
end
