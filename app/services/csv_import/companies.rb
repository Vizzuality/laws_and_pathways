module CSVImport
  class Companies < BaseImporter
    include Helpers

    # rubocop:disable Layout/LineLength
    def import
      import_each_csv_row(csv) do |row|
        company = prepare_company(row)

        company.name = row[:name] if row.header?(:name)
        company.isin = row[:isin] if row.header?(:isin)
        company.sector = find_or_create_tpi_sector(row[:sector]) if row.header?(:sector)
        company.market_cap_group = row[:market_cap_group].downcase if row.header?(:market_cap_group)
        company.sedol = row[:sedol] if row.header?(:sedol)
        company.geography = find_geography(row[:geography_iso]) if row.header?(:geography_iso)
        company.headquarters_geography = find_geography(row[:headquarters_geography_iso]) if row.header?(:headquarters_geography_iso)
        company.latest_information = row[:latest_information] if row.header?(:latest_information)
        company.company_comments_internal = row[:company_comments_internal] if row.header?(:company_comments_internal)
        company.ca100 = row[:ca100] || false if row.header?(:ca100)
        company.active = row[:active] || true if row.header?(:active)
        company.visibility_status = row[:visibility_status]&.downcase if row.header?(:visibility_status)

        was_new_record = company.new_record?
        any_changes = company.changed?

        company.save!

        update_import_results(was_new_record, any_changes)
      end
    end
    # rubocop:enable Layout/LineLength

    private

    def resource_klass
      Company
    end

    def required_headers
      [:id]
    end

    def prepare_company(row)
      return prepare_overridden_resource(row) if override_id

      find_record_by(:id, row) ||
        find_record_by(:isin, row) ||
        find_record_by(:name, row) ||
        resource_klass.new
    end
  end
end
