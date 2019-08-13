module UploaderHelpers
  # def csv
  #   return @csv if defined?(@csv)
  #   file = Paperclip.io_adapters.for(csv_upload.data)
  #   encoding = CharlockHolmes::EncodingDetector.detect(file.read)[:encoding]
  #   @csv = CSV.open(file.path, 'r', headers: true, encoding: encoding).read
  # end

  def parse_headers(headers)
    csv.headers.map do |header|
      headers.
        transform_values(&:downcase).
        key(header.to_s.downcase.gsub(/\s+/, ' ').strip) || header
    end
  end

  def valid_headers?(headers)
    (headers.keys - parse_headers(headers)).each do |value|
      errors.add(:base, :missing_header, msg: "Missing header #{value}", row: 1)
    end
  end

  def add_error(type, message, attrs = {})
    errors.add(:base, type, msg: message, **attrs)
    false
  end
end
