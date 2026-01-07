require 'berkeley_library/logging'
require 'berkeley_library/location/constants'

module BerkeleyLibrary
  module Location
    class XLSXWriter
      include Constants
      include BerkeleyLibrary::Logging

      COL_SLFN = 'SLFN'.freeze
      COL_SLFS = 'SLFS'.freeze
      COL_OTHER_UC = 'Other UC'.freeze
      COL_WC_ERROR = 'WorldCat Error'.freeze

      COL_HATHI_TRUST = 'Hathi Trust'.freeze
      COL_HATHI_TRUST_ERROR = "#{COL_HATHI_TRUST} Error".freeze

      V_SLFN = 'slfn'.freeze
      V_SLFS = 'slfs'.freeze

      attr_reader :ss, :slf, :uc, :hathi_trust

      def initialize(ss, slf: true, uc: true, hathi_trust: true)
        @ss = ss
        @slf = slf
        @uc = uc
        @hathi_trust = hathi_trust

        ensure_columns!
      end

      def <<(result)
        r_indices = row_indices_for(result.oclc_number)
        r_indices.each do |idx|
          write_wc_cols(idx, result) if slf || uc
          write_ht_cols(idx, result) if hathi_trust
        end
      end

      private

      def write_wc_cols(r_index, result)
        write_wc_error(r_index, result)
        write_slf(r_index, result) if slf
        write_uc(r_index, result) if uc
      end

      def write_ht_cols(r_index, result)
        write_ht_error(r_index, result)
        write_hathi(r_index, result)
      end

      def ensure_columns!
        if slf
          slfn_col_index
          slfs_col_index
        end
        uc_col_index if uc
        ht_col_index if hathi_trust
      end

      def row_indices_for(oclc_number)
        row_index = row_indices_by_oclc_number[oclc_number]
        return row_index if row_index

        raise ArgumentError, "Unknown OCLC number: #{oclc_number}"
      end

      def write_slf(r_index, result)
        ss.set_value_at(r_index, slfn_col_index, V_SLFN) if result.slfn?
        ss.set_value_at(r_index, slfs_col_index, V_SLFS) if result.slfs?
      end

      def write_uc(r_index, result)
        return if (uc_symbols = result.uc_symbols).empty?

        ss.set_value_at(r_index, uc_col_index, uc_symbols.join(','))
      end

      def write_hathi(r_index, result)
        return unless (ht_record_url = result.ht_record_url)

        ss.set_value_at(r_index, ht_col_index, ht_record_url)
      end

      def write_wc_error(r_index, result)
        return unless (wc_error = result.wc_error)

        ss.set_value_at(r_index, wc_err_col_index, wc_error)
      end

      def write_ht_error(r_index, result)
        return unless (ht_error = result.ht_error)

        ss.set_value_at(r_index, ht_err_col_index, ht_error)
      end

      def oclc_col_index
        @oclc_col_index ||= ss.find_column_index_by_header!(OCLC_COL_HEADER)
      end

      def slfn_col_index
        @slfn_col_index ||= ss.ensure_column!(COL_SLFN)
      end

      def slfs_col_index
        @slfs_col_index ||= ss.ensure_column!(COL_SLFS)
      end

      def uc_col_index
        @uc_col_index ||= ss.ensure_column!(COL_OTHER_UC)
      end

      def wc_err_col_index
        @wc_err_col_index ||= ss.ensure_column!(COL_WC_ERROR)
      end

      def ht_col_index
        @ht_col_index ||= ss.ensure_column!(COL_HATHI_TRUST)
      end

      def ht_err_col_index
        @ht_err_col_index ||= ss.ensure_column!(COL_HATHI_TRUST_ERROR)
      end

      def row_indices_by_oclc_number
        # Start at 1 to skip header row
        @row_indices_by_oclc_number ||= (1...ss.row_count).each_with_object({}) do |r_index, r_indices|
          oclc_number_raw = ss.value_at(r_index, oclc_col_index)
          next unless oclc_number_raw

          oclc_number = oclc_number_raw.to_s
          r_indices[oclc_number] ||= []
          r_indices[oclc_number] << r_index
        end
      end
    end
  end
end
