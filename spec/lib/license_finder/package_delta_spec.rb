# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe PackageDelta do
    describe '#<=>' do
      let(:foo) { Package.new('foo') }
      let(:bar) { Package.new('bar') }

      it 'sorts by status (added, removed, unchanged)' do
        p1 = PackageDelta.added(foo)
        p2 = PackageDelta.removed(bar)
        p3 = PackageDelta.unchanged(foo, bar)

        expect([p3, p2, p1].sort).to eq([p1, p2, p3])
      end
    end
  end
end
