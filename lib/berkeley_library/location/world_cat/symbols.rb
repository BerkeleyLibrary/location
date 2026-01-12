module BerkeleyLibrary
  module Location
    module WorldCat
      module Symbols
        SLFN = %w[ZAP ZAPSP].freeze
        SLFS = %w[HH0 ZAS ZASSP].freeze
        SLF = (SLFN + SLFS).freeze

        UC = %w[CLU CRU CUI CUN CUS CUT CUV CUX CUY CUZ MERUC].freeze
        ALL = (SLF + UC).freeze

        class << self
          include Symbols
        end

        def valid?(sym)
          ALL.include?(sym)
        end

        def ensure_valid!(symbols)
          raise ArgumentError, "Not a list of institution symbols: #{symbols.inspect}" unless array_like?(symbols)
          raise ArgumentError, 'No institution symbols provided' if symbols.empty?

          return symbols unless (invalid = symbols.reject { |s| Symbols.valid?(s) }).any?

          raise ArgumentError, "Invalid institution symbol(s): #{invalid.map(&:inspect).join(', ')}"
        end

        private

        def array_like?(a)
          %i[reject empty?].all? { |m| a.respond_to?(m) }
        end
      end
    end
  end
end
