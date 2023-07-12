require 'rubyXL/convenience_methods'

module Api
  class CSVToExcel
    attr_accessor :csv, :workbook

    def initialize(csv)
      @csv = csv
      @workbook ||= RubyXL::Workbook.new
    end

    def call
      workbook.add_worksheet name: 'Worksheet'
      copy_paste_data_to workbook[0]
      workbook[0].change_row_bold 0, true
      workbook.stream.string
    end

    private

    def copy_paste_data_to(sheet)
      CSV.parse(csv).each_with_index do |row, i|
        row.each_with_index do |cell, j|
          sheet.add_cell i, j, cell
          set_width_for sheet, j, cell
        end
      end
    end

    def set_width_for(sheet, column_number, text)
      width = [text.to_s.size * 1.1, 100].min
      return if max_widths[column_number].to_i >= width

      sheet.change_column_width column_number, width
      max_widths[column_number] = width
    end

    def max_widths
      @max_widths ||= {}
    end
  end
end
