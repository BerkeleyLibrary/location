require 'json'
require 'singleton'

module BerkeleyLibrary
  module Location
    module WorldCat
      class OCLCAuth
        include Singleton

        attr_accessor :token

        def initialize
          # Sorry Rubocop - needs to be ||= because we're dealing with a singleton
          # rubocop:disable Lint/DisjunctiveAssignmentInConstructor
          @token ||= fetch_token
          # rubocop:enable Lint/DisjunctiveAssignmentInConstructor:
        end

        def fetch_token
          url = oclc_token_url

          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = url.scheme == 'https'

          # Skip SSL verification ONLY when recording new VCR cassettes
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE if ENV['RE_RECORD_VCR'] == 'true'

          request = Net::HTTP::Post.new(url.request_uri)
          request.basic_auth(Config.api_key, Config.api_secret)
          request['Accept'] = 'application/json'
          response = http.request(request)

          JSON.parse(response.body, symbolize_names: true)
        end

        def oclc_token_url
          URI.parse("#{Config.token_uri}?#{URI.encode_www_form(token_params)}")
        end

        # Before every request check if the token is expired (OCLC tokens expire after 20 minutes)
        def access_token
          @token = fetch_token if token_expired?
          @token[:access_token]
        end

        private

        def token_params
          {
            grant_type: 'client_credentials',
            scope: 'wcapi:view_institution_holdings'
          }
        end

        def token_expired?
          return true if @token.nil? || @token[:expires_at].nil?

          Time.parse(@token[:expires_at]) <= Time.now
        end

      end
    end
  end
end
