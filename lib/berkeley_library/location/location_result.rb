require 'berkeley_library/location/world_cat/symbols'

module BerkeleyLibrary
  module Location
    class LocationResult
      attr_reader :oclc_number, :wc_symbols, :ht_record_url, :wc_error, :ht_error

      def initialize(oclc_number, wc_symbols: [], wc_error: nil, ht_record_url: nil, ht_error: nil)
        @oclc_number = oclc_number
        @wc_symbols = wc_symbols
        @wc_error = wc_error
        @ht_record_url = ht_record_url
        @ht_error = ht_error
      end

      def slfn?
        @has_slfn ||= wc_symbols.intersection(WorldCat::Symbols::SLFN).any?
      end

      def slfs?
        @has_slfs ||= wc_symbols.intersection(WorldCat::Symbols::SLFS).any?
      end

      def uc_symbols
        @uc_symbols ||= wc_symbols.intersection(WorldCat::Symbols::UC)
      end
    end
  end
end
