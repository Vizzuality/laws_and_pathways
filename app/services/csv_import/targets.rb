module CSVImport
  class Targets < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        if override_id && Target.where(id: row[:id]).any?
          puts "skipping #{row[:id]}"
          next
        end
        target = prepare_target(row)

        target.target_type = row[:target_type]&.downcase&.gsub(' ', '_') if row.header?(:target_type)
        target.source = row[:source]&.downcase if row.header?(:source)
        target.description = row[:description].presence if row.header?(:description)
        target.ghg_target = row[:ghg_target] if row.header?(:ghg_target)
        target.year = row[:year] if row.header?(:year)
        target.base_year_period = row[:base_year_period].presence if row.header?(:base_year_period)
        target.single_year = row[:single_year] if row.header?(:single_year)
        target.geography = find_geography(row[:geography_iso]) if row.header?(:geography_iso)
        target.sector = find_or_create_laws_sector(row[:sector]) if row.header?(:sector)
        target.legislation_ids = parse_ids(row[:legislation_ids]) if row.header?(:legislation_ids)
        target.scopes = parse_tags(row[:scopes], scopes) if row.header?(:scopes)
        target.visibility_status = row[:visibility_status]&.downcase if row.header?(:visibility_status)

        was_new_record = target.new_record?
        any_changes = target.changed?

        target.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Target
    end

    def required_headers
      [:id]
    end

    def prepare_target(row)
      return prepare_overridden_resource(row) if override_id

      find_record_by(:id, row) || resource_klass.new
    end
  end
end
