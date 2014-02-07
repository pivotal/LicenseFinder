require 'spec_helper'

describe LicenseFinder::License, "Python" do
  it "should be findable" do
    described_class.find_by_name("Python").should be
  end
end
