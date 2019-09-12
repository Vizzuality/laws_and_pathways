module CSVImport
  class Companies < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        company = prepare_company(row)

        company.assign_attributes(company_attributes(row))

        was_new_record = company.new_record?
        any_changes = company.changed?

        company.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Company
    end

    def prepare_company(row)
      find_record_by(:id, row) ||
        find_record_by(:isin, row) ||
        find_record_by(:name, row) ||
        resource_klass.new
    end

    # Builds resource attributes from a CSV row.
    #
    # If not present in DB, will create related:
    # - sector
    #
    def company_attributes(row)
      {
        id: row[:id],
        name: row[:name],
        isin: row[:isin],
        sector: find_or_create_sector(row),
        size: row[:size],
        geography: geographies[row[:geography_iso]],
        headquarters_geography: geographies[row[:headquarters_geography_iso]],
        ca100: row[:ca100],
        visibility_status: row[:visibility_status]
      }
    end

    def find_or_create_sector(row)
      return unless row[:sector].present?

      Sector.where('lower(name) = ?', row[:sector].downcase).first ||
        Sector.new(name: row[:sector])
    end
  end
end
