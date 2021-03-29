module CSVImport
  class Companies < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        company = prepare_company(row)

        company.name = row[:name] if row.header?(:name)
        company.isin = row[:isin] if row.header?(:isin)
        company.sector = find_or_create_tpi_sector(row[:sector]) if row.header?(:sector)
        company.market_cap_group = row[:market_cap_group].downcase if row.header?(:market_cap_group)
        company.geography = geographies[row[:geography_iso]] if row.header?(:geography_iso)
        company.headquarters_geography = geographies[row[:headquarters_geography_iso]] if row.header?(:headquarters_geography_iso)
        company.ca100 = row[:ca100] || false if row.header?(:ca100)
        company.sedol = row[:sedol] if row.header?(:sedol)
        company.latest_information = row[:latest_information] if row.header?(:latest_information)
        company.company_comments_internal = row[:company_comments_internal] if row.header?(:company_comments_internal)
        company.visibility_status = row[:visibility_status] if row.header?(:visibility_status)
        company.active = row[:active] || true if row.header?(:active)

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
  end
end
