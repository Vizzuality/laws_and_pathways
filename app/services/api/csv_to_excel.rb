module Api
  class CSVToExcel
    attr_accessor :csv, :package, :workbook

    def initialize(csv)
      @csv = csv
      @package = Axlsx::Package.new
      @workbook = @package.workbook
    end

    def call
      workbook.add_worksheet(name: 'Worksheet') do |sheet|
        copy_paste_data_to sheet
        sheet.row_style 0, workbook.styles.add_style(b: true)
      end
      package.to_stream.read
    end

    private

    def copy_paste_data_to(sheet)
      CSV.parse(csv).each do |row|
        sheet.add_row row, types: ([:string] * row.size)
      end
    end
  end
end
