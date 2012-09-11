require 'spec_helper'

describe LicenseFinder::License::SimplifiedBSD do
  subject { LicenseFinder::License::SimplifiedBSD.new("") }

  it_behaves_like "a license matcher"
end
