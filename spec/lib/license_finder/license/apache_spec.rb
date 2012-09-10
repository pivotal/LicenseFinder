require 'spec_helper'

describe LicenseFinder::License::Apache do
  subject { LicenseFinder::License::Apache.new("") }

  it_behaves_like "a license matcher"
end
