module CSVImport
  class Companies < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        check_permissions_for_row(row)

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
      return prepare_overridden_resource(row) if override_id

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
        name: row[:name],
        isin: row[:isin],
        sector: find_or_create_tpi_sector(row[:sector]),
        market_cap_group: row[:market_cap_group].downcase,
        geography: geographies[row[:geography_iso]],
        headquarters_geography: geographies[row[:headquarters_geography_iso]],
        ca100: row[:ca100] || false,
        sedol: row[:sedol],
        latest_information: row[:latest_information],
        historical_comments: row[:historical_comments],
        visibility_status: row[:visibility_status]
      }
    end
  end
end
