module ControllerHelpers
  def response_as_csv
    io = StringIO.new(response.body)
    io.set_encoding_by_bom
    CSV.parse(io, headers: true)
  end
end
