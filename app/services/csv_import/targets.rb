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

        target.assign_attributes(target_attributes(row))

        was_new_record = target.new_record?
        any_changes = target.changed?

        target.save!
        target.scopes = parse_tags(row[:scopes], scopes)

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Target
    end

    def prepare_target(row)
      return prepare_overridden_resource(row) if override_id

      find_record_by(:id, row) || resource_klass.new
    end

    # Builds resource attributes from a CSV row.
    #
    # If not present in DB, will create related:
    # - sector
    #
    def target_attributes(row)
      {
        target_type: row[:target_type]&.downcase&.gsub(' ', '_'),
        description: row[:description],
        ghg_target: row[:ghg_target],
        year: row[:year],
        base_year_period: row[:base_year_period],
        single_year: row[:single_year],
        geography: geographies_names[row[:geography]],
        sector: find_or_create_laws_sector(row[:sector]),
        source: row[:source]&.downcase,
        visibility_status: row[:visibility_status],
        legislation_ids: parse_ids(row[:legislation_ids])
      }
    end
  end
end
