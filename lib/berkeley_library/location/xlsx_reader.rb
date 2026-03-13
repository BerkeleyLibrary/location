require 'marcel'
require 'rubyXL'
require 'berkeley_library/location/constants'
require 'berkeley_library/util/xlsx/spreadsheet'

module BerkeleyLibrary
  module Location
    class XLSXReader
      include Constants

      attr_reader :ss, :oclc_col_index

      def initialize(xlsx_path)
        @ss = Util::XLSX::Spreadsheet.new(xlsx_path)
        @oclc_col_index = ss.find_column_index_by_header!(OCLC_COL_HEADER)
      end

      def each_oclc_number
        return to_enum(:each_oclc_number) unless block_given?

        ss.each_value(oclc_col_index, include_header: false) do |v|
          # convert to integer if oclc number is a float in the spreadsheet
          v = v.to_i if v.is_a?(Float)
          next if (v_str = v.to_s).strip == ''

          yield v_str
        end
      end
    end
  end
end
