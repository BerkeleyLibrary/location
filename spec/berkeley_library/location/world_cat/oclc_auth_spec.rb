require 'spec_helper'
require 'time'

module BerkeleyLibrary
  module Location
    module WorldCat
      describe OCLCAuth do
        it 'fetches a token' do
          VCR.use_cassette('oclc_auth/fetch_token') do
            token = OCLCAuth.instance.token
            expect(token).to be_a(Hash)
            expect(token[:access_token]).to be_a(String)
          end
        end

        it 'refreshes an expired token' do
          VCR.use_cassette('oclc_auth/refresh_token') do
            # First get a token....
            token = OCLCAuth.instance.token

            # Need to set the token expiration to a time in the past
            token[:expires_at] = (Time.now - 60).to_s
            token[:access_token] = 'expired_token'

            # Now we need to set the token instance to the token with the updated expiration
            OCLCAuth.instance.token = token

            # Trigger a refresh by calling access_token
            OCLCAuth.instance.access_token

            # Now check that the token has been refreshed
            token = OCLCAuth.instance.token

            expect(token[:access_token]).not_to eq('expired_token')
            expect(Time.parse(token[:expires_at])).to be >= Time.now
          end
        end

        describe '#access_token' do
          subject(:oclc_auth) { described_class.instance }

          after do
            # Reset token so other tests aren't affected
            oclc_auth.instance_variable_set(:@token, nil)
          end

          it 'returns the current token if not expired' do
            oclc_auth.instance_variable_set(:@token, { access_token: 'existing-token', expires_at: (Time.now + 60).to_s })
            expect(oclc_auth.access_token).to eq('existing-token')
          end

          it 'fetches a new token if expired' do
            allow(oclc_auth).to receive(:fetch_token).and_return({ access_token: 'new-token', expires_at: (Time.now + 3600).to_s })
            oclc_auth.instance_variable_set(:@token, { access_token: 'old-token', expires_at: (Time.now - 60).to_s })
            expect(oclc_auth.access_token).to eq('new-token')
          end

          describe '#token_expired?' do
            subject(:oclc_auth) { described_class.instance }

            it 'returns true if @token is nil' do
              oclc_auth.instance_variable_set(:@token, nil)
              expect(oclc_auth.send(:token_expired?)).to be true
            end

            it 'returns true if token is expired' do
              oclc_auth.instance_variable_set(:@token, { access_token: 'x', expires_at: (Time.now - 1).to_s })
              expect(oclc_auth.send(:token_expired?)).to be true
            end

            it 'returns false if token is still valid' do
              oclc_auth.instance_variable_set(:@token, { access_token: 'x', expires_at: (Time.now + 60).to_s })
              expect(oclc_auth.send(:token_expired?)).to be false
            end
          end
        end

        describe '#skip_ssl_verification?' do
          subject(:oclc_auth) { described_class.instance }

          it 'returns true when RE_RECORD_VCR=true' do
            allow(ENV).to receive(:[]).with('RE_RECORD_VCR').and_return('true')
            expect(oclc_auth.send(:skip_ssl_verification?)).to be true
          end
        end

        describe '#fetch_token (SSL verification false branch)' do
          subject(:oclc_auth) { described_class.instance }

          let(:url) { URI('https://example.test/token') }
          let(:http) { instance_double(Net::HTTP) }
          let(:response) do
            instance_double(Net::HTTPResponse, body: '{"access_token":"abc"}')
          end

          before do
            allow(oclc_auth).to receive(:skip_ssl_verification?).and_return(false)
            allow(oclc_auth).to receive(:oclc_token_url).and_return(url)

            allow(Net::HTTP).to receive(:new).and_return(http)
            allow(http).to receive(:use_ssl=).with(true)
            allow(http).to receive(:request).and_return(response)

            allow(Config).to receive(:api_key).and_return('key')
            allow(Config).to receive(:api_secret).and_return('secret')
          end

          after do
            oclc_auth.instance_variable_set(:@token, nil)
          end

          it 'does not disable SSL verification when skip_ssl_verification? is false' do
            expect(http).not_to receive(:verify_mode=)

            oclc_auth.send(:fetch_token)
          end
        end
      end
    end
  end
end
