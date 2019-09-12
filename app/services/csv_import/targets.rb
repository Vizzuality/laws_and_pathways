module CSVImport
  class Targets < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        target = prepare_target(row)

        # puts target_attributes(row)
        target.assign_attributes(target_attributes(row))

        was_new_record = target.new_record?
        any_changes = target.changed?
        # puts ['changes', target.changes]

        target.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Target
    end

    def prepare_target(row)
      find_record_by(:id, row) || resource_klass.new
    end

    # Builds resource attributes from a CSV row.
    #
    # If not present in DB, will create related:
    # - sector
    #
    def target_attributes(row)
      {
        id: row[:id],
        target_type: row[:target_type],
        description: row[:description],
        ghg_target: row[:ghg_target],
        year: row[:year],
        base_year_period: row[:base_year_period],
        single_year: row[:single_year],
        geography: geographies[row[:geography_iso]],
        sector: find_or_create_sector(row[:sector]),
        target_scope: find_target_scope(row[:target_scope]),
        visibility_status: row[:visibility_status]
      }
    end

    def find_or_create_sector(sector_name)
      return unless sector_name.present?

      Sector.where('lower(name) = ?', sector_name.downcase).first ||
        Sector.new(name: sector_name)
    end

    def find_target_scope(target_scope_name)
      TargetScope.where('lower(name) = ?', target_scope_name.downcase).first
    end
  end
end
