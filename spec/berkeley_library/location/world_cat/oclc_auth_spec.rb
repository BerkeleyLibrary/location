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

        describe '#token_expired?' do
          subject(:oclc_auth) { described_class.instance }

          it 'returns true if @token is nil' do
            oclc_auth.instance_variable_set(:@token, nil)
            expect(oclc_auth.send(:token_expired?)).to be true
          end
        end
      end
    end
  end
end
