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
    workbook = Roo::Excelx.new(io)
    workbook.sheet(0).parse(headers: true, clean: true)[1..].map do |hash|
      hash.transform_keys { |key| key.gsub(/[\u200B-\u200D\uFEFF]/, '') }
    end.to_json
  end
end
