module CSVImport
  class Targets < BaseImporter
    include UploaderHelpers

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
        target.legislations = connect_laws(row[:source_documents])

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
        target_type: row[:type]&.downcase&.gsub(' ', '_'),
        description: row[:full_description],
        ghg_target: (row[:ghg_target] == 'ghg'),
        year: row[:year],
        base_year_period: row[:base_year_period],
        single_year: (row[:single_year] == 'single year'),
        geography: geographies_names[row[:country]],
        sector: find_or_create_laws_sector(row[:sector]),
        visibility_status: row[:visibility_status]
      }
    end

    def connect_laws(documents)
      return [] unless documents

      laws = []
      documents.split(';').each do |doc|
        contents = doc.split('|')
        next unless contents.size == 3 && contents[1].to_i != 0
        find_it = Legislation.find(contents[1])
        laws << find_it
      end
      laws
    end
  end
end
