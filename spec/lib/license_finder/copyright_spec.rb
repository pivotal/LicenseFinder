# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Copyright do
    describe '.find_by_text' do
      it 'returns nil if not found' do
        copyright = Copyright.find_by_text('foo')

        expect(copyright).to be_nil
      end

      it 'should find a simple copyright' do
        copyright = Copyright.find_by_text('Copyright 2020 by Sven')
        expect(copyright.copyright).to eq 'Copyright 2020 by Sven'
        expect(copyright.owners).to eq 'Sven'
      end

      it 'should find a copyright with additional symbol' do
        copyright = Copyright.find_by_text('Copyright © 2020 Sven')
        expect(copyright.copyright).to eq 'Copyright © 2020 Sven'
        expect(copyright.owners).to eq 'Sven'
      end

      it 'should find a copyright by symbol' do
        copyright = Copyright.find_by_text('(c) 2020-present by Sven')
        expect(copyright.copyright).to eq '(c) 2020-present by Sven'
        expect(copyright.owners).to eq 'Sven'
      end

      it 'should find a copyright with year range' do
        copyright = Copyright.find_by_text('(c) 2020-2020 by Sven')
        expect(copyright.copyright).to eq '(c) 2020-2020 by Sven'
        expect(copyright.owners).to eq 'Sven'
      end

      it 'should find multiple copyright owners' do
        copyright = Copyright.find_by_text('Copyright 2020 by Sven, Sven, Sven')
        expect(copyright.copyright).to eq 'Copyright 2020 by Sven, Sven, Sven'
        expect(copyright.owners).to eq 'Sven, Sven, Sven'
      end

      it 'should find copyright owner with email' do
        copyright = Copyright.find_by_text('Copyright 2020 sven@mail.com, Sven <sven@mail.com>, [Sven](sven@mail.com)')
        expect(copyright.copyright).to eq 'Copyright 2020 sven@mail.com, Sven <sven@mail.com>, [Sven](sven@mail.com)'
        expect(copyright.owners).to eq 'sven@mail.com, Sven <sven@mail.com>, [Sven](sven@mail.com)'
      end

      it 'should find a copyright as part of license note' do
        copyright = Copyright.find_by_text("This gem is licensed under the MIT License\n\nCopyright © 2020 by Sven\n\nThe MIT License")
        expect(copyright.copyright).to eq 'Copyright © 2020 by Sven'
        expect(copyright.owners).to eq 'Sven'
      end

      it 'should find a copyright mentioned as a comment' do
        copyright = Copyright.find_by_text("This gem is licensed under the MIT License\n\n> * &copy; 2020 by Sven")
        expect(copyright.copyright).to eq '&copy; 2020 by Sven'
        expect(copyright.owners).to eq 'Sven'
      end
    end
  end
end
