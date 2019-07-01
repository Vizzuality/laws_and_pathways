module CSVImporter
  extend ActiveSupport::Concern

  def parse_csv(file)
    hard_space_converter = ->(f) { f&.gsub(160.chr('UTF-8'), 32.chr) }
    strip_converter = ->(field, _) { field&.strip }

    CSV.parse(
      file.body.read,
      headers: true,
      skip_blanks: true,
      converters: [hard_space_converter, strip_converter],
    ).delete_if { |row| row.to_hash.values.all?(&:blank?) }
  end
end
