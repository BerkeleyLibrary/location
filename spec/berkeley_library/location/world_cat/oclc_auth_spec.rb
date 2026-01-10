require 'spec_helper'
require 'time'
require 'active_support/testing/time_helpers'

module BerkeleyLibrary
  module Location
    module WorldCat
      describe OCLCAuth do
        include ActiveSupport::Testing::TimeHelpers

        it 'fetches a token' do
          VCR.use_cassette('oclc_auth/fetch_token') do
            token = OCLCAuth.instance.token
            expect(token).to be_a(Hash)
            expect(token[:access_token]).to be_a(String)
          end
        end

        it 'refreshes an expired token' do
          freeze_time do
            auth = OCLCAuth.instance

            # Simulate an expired token
            expired_token = { access_token: 'expired_token', expires_at: (Time.current - 60).to_s }
            auth.token = expired_token

            # Stub fetch_token to return a fresh token
            new_token = { access_token: 'new_token', expires_at: (Time.current + 3600).to_s }
            allow(auth).to receive(:fetch_token).and_return(new_token)

            # Trigger a refresh by calling access_token
            result = auth.access_token

            # Check that the token was refreshed
            expect(result).to eq('new_token')
            expect(auth.token[:access_token]).to eq('new_token')
            expect(Time.parse(auth.token[:expires_at])).to be >= Time.current
          end
        end

        describe '#token_expired?' do
          subject(:oclc_auth) { described_class.instance }

          it 'returns true if @token is nil' do
            oclc_auth.instance_variable_set(:@token, nil)
            expect(oclc_auth.send(:token_expired?)).to be true
          end
        end

        describe '#fetch_token SSL branch' do
          it 'does not disable SSL verification when RE_RECORD_VCR is not true' do
            # Clear RE_RECORD_VCR
            allow(ENV).to receive(:[]).with('RE_RECORD_VCR').and_return(nil)

            url = URI('https://example.test/token')
            http = instance_double(Net::HTTP)
            allow(Net::HTTP).to receive(:new).and_return(http)
            allow(http).to receive(:use_ssl=)
            allow(http).to receive(:request).and_return(double(body: '{"access_token":"abc"}'))

            auth = OCLCAuth.instance
            allow(auth).to receive(:oclc_token_url).and_return(url)
            allow(Config).to receive(:api_key).and_return('key')
            allow(Config).to receive(:api_secret).and_return('secret')

            expect(http).not_to receive(:verify_mode=)
            auth.send(:fetch_token)
          end

          it 'disables SSL verification when RE_RECORD_VCR is true' do
            # Force the env to true
            allow(ENV).to receive(:[]).with('RE_RECORD_VCR').and_return('true')

            url = URI('https://example.test/token')
            http = instance_double(Net::HTTP)
            allow(Net::HTTP).to receive(:new).and_return(http)
            allow(http).to receive(:use_ssl=)
            allow(http).to receive(:request).and_return(double(body: '{"access_token":"abc"}'))

            auth = OCLCAuth.instance
            allow(auth).to receive(:oclc_token_url).and_return(url)
            allow(Config).to receive(:api_key).and_return('key')
            allow(Config).to receive(:api_secret).and_return('secret')

            # Expect that verify_mode is set when ENV is 'true'
            expect(http).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
            auth.send(:fetch_token)
          end
        end

        describe '#access_token' do
          it 'returns existing token if not expired' do
            auth = OCLCAuth.instance
            future_token = { access_token: 'valid-token', expires_at: (Time.now + 3600).to_s }
            auth.token = future_token

            expect(auth.access_token).to eq('valid-token')
          end
        end

      end
    end
  end
end
