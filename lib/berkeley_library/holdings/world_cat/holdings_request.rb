require 'nokogiri'
require 'rest-client'
require 'berkeley_library/util'

module BerkeleyLibrary
  module Holdings
    module WorldCat
      # @see https://developer.api.oclc.org/wcv1#/Holdings
      class HoldingsRequest
        include BerkeleyLibrary::Logging
        include BerkeleyLibrary::Util

        XPATH_INST_ID_VALS = '/holdings/holding/institutionIdentifier/value'.freeze

        attr_reader :oclc_number, :symbols

        def initialize(oclc_number, symbols: Symbols::ALL)
          @oclc_number = OCLCNumber.ensure_oclc_number!(oclc_number)
          @symbols = Symbols.ensure_valid!(symbols)
        end

        def uri
          @uri ||= URIs.append(holdings_base_uri, oclc_number)
        end

        def params
          @params ||= {
            'oclcsymbol' => symbols.join(','),
            'servicelevel' => 'full',
            'frbrGrouping' => 'off',
            'wskey' => Config.api_key
          }
        end

        def execute
          response = RestClient.get(uri.to_s, { params: })
          holdings_syms = holdings_from(response.body)
          holdings_syms.select { |sym| symbols.include?(sym) } # just in case
        rescue StandardError => e
          logger.warn("Error retrieving holdings for #{oclc_number.inspect}, symbols: #{symbols.inspect}", e)
          []
        end

        private

        def holdings_base_uri
          URIs.append(Config.base_uri, 'catalog', 'content', 'libraries')
        end

        def holdings_from(xml)
          xml_doc = Nokogiri::XML(xml)
          id_vals = xml_doc.xpath(XPATH_INST_ID_VALS)
          id_vals.filter_map { |value| value.text&.strip }
        end
      end
    end
  end
end
