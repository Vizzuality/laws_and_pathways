require 'rubyXL/convenience_methods'

module ControllerHelpers
  def response_as_csv
    io = StringIO.new(response.body)
    io.set_encoding_by_bom
    CSV.parse(io, headers: true)
  end

  def parse_csv_to_json(csv)
    io = StringIO.new(csv)
    io.set_encoding_by_bom
    CSV.parse(io, headers: true).map(&:to_h).to_json
  end

  def parse_xlsx_to_json(csv)
    io = StringIO.new(csv)
    io.set_encoding_by_bom
    workbook = RubyXL::Parser.parse_buffer io
    headers = workbook[0].sheet_data.rows[0].cells.map(&:value).map { |h| h&.gsub(/[\u200B-\u200D\uFEFF]/, '') }
    workbook[0].sheet_data.rows.each_with_object([]).with_index do |(row, result), i|
      next if i.zero?

      result[i - 1] = {}
      row.cells.each_with_index do |cell, j|
        result[i - 1][headers[j]] = cell.value
      end
    end.to_json
  end
end
