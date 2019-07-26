module ImportHelpers
  def find_location(country_iso)
    Location.find_by!(iso: country_iso)
  rescue StandardError
    puts "Couldn't find Location with ISO: #{country_iso}"
  end

  def try_to_parse_date(date, expected_date_formats)
    expected_date_formats.map { |format| parse_date(date, format) }.compact.first
  end

  def parse_date(date, format)
    Date.strptime(date, format)
  rescue ArgumentError
    nil
  end
end
