require 'spec_helper'

module BerkeleyLibrary
  module Location
    describe XLSXReader do
      describe :new do
        context 'invalid formats' do
          it 'rejects an Excel 95 (.xls) workbook' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-excel95.xls'

            expect { XLSXReader.new(xls_path) }.to raise_error(ArgumentError)
          end

          it 'rejects an Excel 97 (.xls) workbook' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-excel97.xls'

            expect { XLSXReader.new(xls_path) }.to raise_error(ArgumentError)
          end

          it 'rejects an Excel 95 workbook renamed to .xlsx' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-excel95-as-xlsx.xlsx'

            expect { XLSXReader.new(xls_path) }.to raise_error(ArgumentError)
          end
        end

        context 'invalid contents' do
          it 'rejects an empty spreadsheet' do
            xlsx_path = 'spec/data/excel/bad/oclc-numbers-empty.xlsx'

            expect { XLSXReader.new(xlsx_path) }.to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet with blank headers' do
            xlsx_path = 'spec/data/excel/bad/oclc-numbers-blank-header.xlsx'

            expect { XLSXReader.new(xlsx_path) }.to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet with empty headers' do
            xlsx_path = 'spec/data/excel/bad/oclc-numbers-empty-header.xlsx'

            expect { XLSXReader.new(xlsx_path) }.to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet without headers' do
            xlsx_path = 'spec/data/excel/bad/oclc-numbers-missing-header.xlsx'

            expect { XLSXReader.new(xlsx_path) }.to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet without an OCLC Numbers column' do
            xlsx_path = 'spec/data/excel/bad/oclc-numbers-no-oclc-col.xlsx'

            expect { XLSXReader.new(xlsx_path) }.to raise_error(ArgumentError)
          end
        end
      end

      describe :each_oclc_number do
        let(:oclc_numbers_expected) { File.readlines('spec/data/excel/oclc_numbers_expected.txt', chomp: true) }

        it 'returns an enumerator if no block given' do
          xlsx_path = 'spec/data/excel/oclc-numbers.xlsx'
          en = XLSXReader.new(xlsx_path).each_oclc_number
          expect(en).to be_a(Enumerator)
          expect(en.to_a).to eq(oclc_numbers_expected)
        end

        it 'finds OCLC numbers as numbers' do
          reader = XLSXReader.new('spec/data/excel/oclc-numbers.xlsx')
          expect { |b| reader.each_oclc_number(&b) }
            .to yield_successive_args(*oclc_numbers_expected)
        end

        # Added this since oclc floats in oclc-numbers-float.xlsx weren't being read
        # in as floats at runtime.
        it 'processes OCLC numbers converted to floats from the base spreadsheet' do
          source_xlsx_path = 'spec/data/excel/oclc-numbers.xlsx'
          source_oclc_numbers = XLSXReader.new(source_xlsx_path).each_oclc_number.to_a

          Dir.mktmpdir(File.basename(__FILE__)) do |tmpdir|
            xlsx_path = File.join(tmpdir, 'oclc-numbers-from-source-as-floats.xlsx')

            ss = BerkeleyLibrary::Util::XLSX::Spreadsheet.new
            c_index = ss.ensure_column!(BerkeleyLibrary::Location::Constants::OCLC_COL_HEADER)
            source_oclc_numbers.each_with_index do |oclc_num, i|
              r_index = 1 + i # skip header row
              ss.set_value_at(r_index, c_index, oclc_num.to_f)
            end
            ss.save_as(xlsx_path)

            reader = XLSXReader.new(xlsx_path)
            expect(reader.each_oclc_number.to_a).to eq(source_oclc_numbers)
          end
        end

        it 'finds OCLC numbers as strings' do
          reader = XLSXReader.new('spec/data/excel/oclc-numbers-text.xlsx')
          expect { |b| reader.each_oclc_number(&b) }
            .to yield_successive_args(*oclc_numbers_expected)
        end

        it 'finds OCLC numbers when column is formatted as Excel number' do
          reader = XLSXReader.new('spec/data/excel/oclc-numbers-float.xlsx')
          expect { |b| reader.each_oclc_number(&b) }
            .to yield_successive_args(*oclc_numbers_expected)
        end

        it 'skips blank cells' do
          reader = XLSXReader.new('spec/data/excel/oclc-numbers-sparse.xlsx')
          expect { |b| reader.each_oclc_number(&b) }
            .to yield_successive_args(*oclc_numbers_expected)
        end

        it 'finds OCLC numbers in later columns' do
          reader = XLSXReader.new('spec/data/excel/oclc-numbers-extra-cols.xlsx')
          expect { |b| reader.each_oclc_number(&b) }
            .to yield_successive_args(*oclc_numbers_expected)
        end

        it 'handles large files' do
          # NOTE: tested with up to 1 million, but it's slow (~2.5 minutes)
          expected_count = 10_000
          oclc_numbers = Array.new(expected_count) { |i| (expected_count + i).to_s }
          oclc_numbers.shuffle!

          Dir.mktmpdir(File.basename(__FILE__)) do |tmpdir|
            xlsx_path = File.join(tmpdir, "#{expected_count}.xlsx")

            ss = BerkeleyLibrary::Util::XLSX::Spreadsheet.new
            c_index = ss.ensure_column!(BerkeleyLibrary::Location::Constants::OCLC_COL_HEADER)
            oclc_numbers.each_with_index do |oclc_num, i|
              r_index = 1 + i # skip header row
              ss.set_value_at(r_index, c_index, oclc_num)
            end
            ss.save_as(xlsx_path)

            reader = XLSXReader.new(xlsx_path)
            expect(reader.each_oclc_number.to_a).to eq(oclc_numbers)
          end
        end

        it 'handles files with missing rows' do
          xlsx_path = 'spec/data/excel/nil-rows.xlsx'
          oclc_numbers = %w[
            482132
            1565651
            1375549
            5070824
            4979728
            10727310
            1777934
            1568580
            17802293
            1777832
            9863947
            42343741
          ]
          reader = XLSXReader.new(xlsx_path)
          expect(reader.each_oclc_number.to_a).to eq(oclc_numbers)
        end
      end

    end
  end
end
