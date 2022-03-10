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
end
