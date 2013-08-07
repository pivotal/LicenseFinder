require 'spec_helper'

describe LicenseFinder::License::Python do
  subject { LicenseFinder::License::Python.new("") }

  it_behaves_like "a license matcher"
end
