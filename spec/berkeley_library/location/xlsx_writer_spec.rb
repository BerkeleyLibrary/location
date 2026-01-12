require 'spec_helper'

module BerkeleyLibrary
  module Location
    describe XLSXWriter do
      describe :<< do
        let(:ss) { Util::XLSX::Spreadsheet.new('spec/data/excel/oclc-numbers.xlsx') }
        let(:oclc_numbers_expected) { File.readlines('spec/data/excel/oclc_numbers_expected.txt', chomp: true) }
        let(:c_index_oclc) { ss.find_column_index_by_header!('OCLC Number') }
        let(:c_index_mmsid) { ss.find_column_index_by_header!('MMSID') }

        let(:oclc_index) { oclc_numbers_expected.size / 2 }
        let(:oclc_number) { oclc_numbers_expected[oclc_index] }
        let(:r_index) { 1 + oclc_index }

        let(:record_url) { 'https://catalog.hathitrust.org/Record/102321413' }

        let(:result) do
          LocationResult.new(
            oclc_number,
            wc_symbols: %w[CLU CUY ZAP ZAS],
            ht_record_url: record_url
          )
        end

        context 'success' do

          it 'writes a result' do
            expected = {
              'OCLC Number' => oclc_number.to_i,
              'SLFN' => 'slfn',
              'SLFS' => 'slfs',
              'Other UC' => 'CLU,CUY',
              'Hathi Trust' => record_url,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index, c_index_mmsid)
            }

            writer = XLSXWriter.new(ss)
            writer << result

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index, c_index)
              expect(v_actual).to eq(v_expected)
            end
          end

          it 'writes a result with WorldCat errors' do
            err_msg = '500 Internal Server Error'

            result = LocationResult.new(
              oclc_number,
              wc_error: err_msg,
              ht_record_url: record_url
            )

            expected = {
              'OCLC Number' => oclc_number.to_i,
              'SLFN' => nil,
              'SLFS' => nil,
              'Other UC' => nil,
              'Hathi Trust' => record_url,
              'WorldCat Error' => err_msg,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index, c_index_mmsid)
            }

            writer = XLSXWriter.new(ss)
            writer << result

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index, c_index)
              expect(v_actual).to eq(v_expected)
            end
          end

          it 'writes a result with HathiTrust errors' do
            err_msg = '500 Internal Server Error'

            result = LocationResult.new(
              oclc_number,
              wc_symbols: %w[CLU CUY ZAP ZAS],
              ht_error: err_msg
            )

            expected = {
              'OCLC Number' => oclc_number.to_i,
              'SLFN' => 'slfn',
              'SLFS' => 'slfs',
              'Other UC' => 'CLU,CUY',
              'Hathi Trust' => nil,
              'Hathi Trust Error' => err_msg,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index, c_index_mmsid)
            }

            writer = XLSXWriter.new(ss)
            writer << result

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index, c_index)
              expect(v_actual).to eq(v_expected)
            end
          end

          it 'writes requested columns even if empty' do
            result = LocationResult.new(oclc_number, ht_record_url: record_url)
            writer = XLSXWriter.new(ss)
            writer << result

            expected = {
              'OCLC Number' => oclc_number.to_i,
              'SLFN' => nil,
              'SLFS' => nil,
              'Other UC' => nil,
              'Hathi Trust' => record_url,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index, c_index_mmsid)
            }

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index, c_index)
              expect(v_actual).to eq(v_expected)
            end
          end

          it 'accepts results that only have non-requested values' do
            result = LocationResult.new(
              oclc_number,
              wc_symbols: %w[CLU CUY ZAP ZAS]
            )

            writer = XLSXWriter.new(ss, slf: false, uc: false)
            writer << result

            expected = {
              'OCLC Number' => oclc_number.to_i,
              'Hathi Trust' => nil,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index, c_index_mmsid)
            }

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index, c_index)
              expect(v_actual).to eq(v_expected)
            end

            ['SLFN', 'SLFS', 'Other UC'].each do |header|
              c_index = ss.find_column_index_by_header(header)
              expect(c_index).to be_nil
            end
          end

          it 'can write a result without a HathiTrust record URL' do
            writer = XLSXWriter.new(ss)
            writer << result

            oclc_index_next = oclc_index / 2
            r_index_next = 1 + oclc_index_next
            oclc_number_next = oclc_numbers_expected[oclc_index_next]

            result_next = LocationResult.new(
              oclc_number_next,
              wc_symbols: %w[CLU CUY ZAP ZAS]
            )
            writer << result_next

            expected = {
              'OCLC Number' => oclc_number_next.to_i,
              'SLFN' => 'slfn',
              'SLFS' => 'slfs',
              'Other UC' => 'CLU,CUY',
              'Hathi Trust' => nil,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index_next, c_index_mmsid)
            }

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index_next, c_index)
              expect(v_actual).to eq(v_expected)
            end
          end

          it 'can write a result without SLFN' do
            writer = XLSXWriter.new(ss)
            writer << result

            oclc_index_next = oclc_index / 2
            r_index_next = 1 + oclc_index_next
            oclc_number_next = oclc_numbers_expected[oclc_index_next]

            result_next = LocationResult.new(
              oclc_number_next,
              wc_symbols: %w[CLU CUY ZAS]
            )
            writer << result_next

            expected = {
              'OCLC Number' => oclc_number_next.to_i,
              'SLFN' => nil,
              'SLFS' => 'slfs',
              'Other UC' => 'CLU,CUY',
              'Hathi Trust' => nil,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index_next, c_index_mmsid)
            }

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index_next, c_index)
              expect(v_actual).to eq(v_expected)
            end
          end

          it 'can write a result without other UCs' do
            writer = XLSXWriter.new(ss)
            writer << result

            oclc_index_next = oclc_index / 2
            r_index_next = 1 + oclc_index_next
            oclc_number_next = oclc_numbers_expected[oclc_index_next]

            result_next = LocationResult.new(
              oclc_number_next,
              wc_symbols: %w[ZAP ZAS]
            )
            writer << result_next

            expected = {
              'OCLC Number' => oclc_number_next.to_i,
              'SLFN' => 'slfn',
              'SLFS' => 'slfs',
              'Other UC' => nil,
              'Hathi Trust' => nil,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index_next, c_index_mmsid)
            }

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index_next, c_index)
              expect(v_actual).to eq(v_expected)
            end
          end

          it 'can write a result without SLFS' do
            writer = XLSXWriter.new(ss)
            writer << result

            oclc_index_next = oclc_index / 2
            r_index_next = 1 + oclc_index_next
            oclc_number_next = oclc_numbers_expected[oclc_index_next]

            result_next = LocationResult.new(
              oclc_number_next,
              wc_symbols: %w[CLU CUY ZAP]
            )
            writer << result_next

            expected = {
              'OCLC Number' => oclc_number_next.to_i,
              'SLFN' => 'slfn',
              'SLFS' => nil,
              'Other UC' => 'CLU,CUY',
              'Hathi Trust' => nil,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index_next, c_index_mmsid)
            }

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index_next, c_index)
              expect(v_actual).to eq(v_expected)
            end
          end

          it 'can skip SLF columns' do
            expected = {
              'OCLC Number' => oclc_number.to_i,
              'Other UC' => 'CLU,CUY',
              'Hathi Trust' => record_url,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index, c_index_mmsid)
            }

            writer = XLSXWriter.new(ss, slf: false)
            writer << result

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index, c_index)
              expect(v_actual).to eq(v_expected)
            end

            %w[SLFN SLFS].each do |col_header|
              c_index = ss.find_column_index_by_header(col_header)
              expect(c_index).to be_nil
            end
          end

          it 'can skip the Other UC column' do
            expected = {
              'OCLC Number' => oclc_number.to_i,
              'SLFN' => 'slfn',
              'SLFS' => 'slfs',
              'Hathi Trust' => record_url,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index, c_index_mmsid)
            }

            writer = XLSXWriter.new(ss, uc: false)
            writer << result

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index, c_index)
              expect(v_actual).to eq(v_expected)
            end

            c_index = ss.find_column_index_by_header('Other UC')
            expect(c_index).to be_nil
          end

          it 'can skip the Hathi Trust column' do
            expected = {
              'OCLC Number' => oclc_number.to_i,
              'SLFN' => 'slfn',
              'SLFS' => 'slfs',
              'Other UC' => 'CLU,CUY',
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index, c_index_mmsid)
            }

            writer = XLSXWriter.new(ss, hathi_trust: false)
            writer << result

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index, c_index)
              expect(v_actual).to eq(v_expected)
            end

            c_index = ss.find_column_index_by_header('Hathi Trust')
            expect(c_index).to be_nil
          end

          it 'does not ignore rows with duplicate OCLC numbers' do
            expected = {
              'OCLC Number' => oclc_number.to_i,
              'SLFN' => 'slfn',
              'SLFS' => 'slfs',
              'Other UC' => 'CLU,CUY',
              'Hathi Trust' => record_url,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index, c_index_mmsid)
            }

            r_index_dup = 1 + oclc_numbers_expected.size
            ss.set_value_at(r_index_dup, c_index_oclc, oclc_number)

            writer = XLSXWriter.new(ss)
            writer << result

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index, c_index)
              expect(v_actual).to eq(v_expected)
            end

            ['SLFN', 'SLFS', 'Other UC', 'Hathi Trust'].each do |col_header|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index_dup, c_index)
              expect(v_actual).to eq(expected[col_header])
            end
          end

          it 'handles spreadsheets with gaps' do
            gap_size = 3
            gap_size.times { ss.worksheet.insert_row(r_index) }
            r_index_new = gap_size + r_index

            expected = {
              'OCLC Number' => oclc_number.to_i,
              'SLFN' => 'slfn',
              'SLFS' => 'slfs',
              'Other UC' => 'CLU,CUY',
              'Hathi Trust' => record_url,
              # check that we preserve existing values
              'MMSID' => ss.value_at(r_index_new, c_index_mmsid)
            }

            writer = XLSXWriter.new(ss)
            writer << result

            expected.each do |col_header, v_expected|
              c_index = ss.find_column_index_by_header!(col_header)
              v_actual = ss.value_at(r_index_new, c_index)
              expect(v_actual).to eq(v_expected)
            end
          end

          it 'overwrites blank columns' do
            ss = Util::XLSX::Spreadsheet.new('spec/data/excel/sparse-table.xlsx')

            oclc_number = '63125872'
            result = LocationResult.new(
              oclc_number,
              wc_symbols: %w[CUI CUT CUV ZAS],
              ht_error: '403 Forbidden'
            )

            expected_values = {
              'OCLC Number' => oclc_number.to_i,
              'Call #' => 'JN3971.A988 D38 2006',
              'Title' => 'Becoming party politicians : eastern German state legislators in the decade following democratization / Louise K. Davidson-Schmich.',
              'SLFN' => nil,
              'SLFS' => 'slfs',
              'Other UC' => 'CUI,CUT,CUV',
              'Hathi Trust' => nil,
              'Hathi Trust Error' => '403 Forbidden'
            }
            r_index = 6

            writer = XLSXWriter.new(ss)
            writer << result

            aggregate_failures do
              expected_values.each_with_index do |(c, v_ex), ci_ex|
                c_index = ss.find_column_index_by_header!(c)
                expect(c_index).to eq(ci_ex)
                v_actual = ss.value_at(r_index, c_index)
                expect(v_actual).to eq(v_ex)
              end
            end
          end
        end

        context 'failure' do

          it 'fails on nonexistent OCLC numbers' do
            bad_oclc_number = (oclc_numbers_expected.map(&:to_i).max * 2).to_s
            bad_result = LocationResult.new(
              bad_oclc_number,
              wc_symbols: %w[CLU CUY ZAP ZAS],
              ht_record_url: record_url
            )

            writer = XLSXWriter.new(ss)
            expect { writer << bad_result }.to raise_error(ArgumentError)
          end

        end
      end
    end
  end
end
