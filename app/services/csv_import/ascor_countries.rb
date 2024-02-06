module CSVImport
  class ASCORCountries < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        country = prepare_country row

        country.name = row[:name] if row.header?(:name)
        country.iso = row[:country_iso_code] if row.header?(:country_iso_code)
        country.region = row[:region] if row.header?(:region)
        country.wb_lending_group = row[:world_bank_lending_group] if row.header?(:world_bank_lending_group)
        if row.header?(:international_monetary_fund_fiscal_monitor_category)
          country.fiscal_monitor_category = row[:international_monetary_fund_fiscal_monitor_category]
        end
        if row.header?(:type_of_party_to_the_united_nations_framework_convention_on_climate_change)
          country.type_of_party = row[:type_of_party_to_the_united_nations_framework_convention_on_climate_change]
        end
        country.visibility_status = row[:visibility_status]&.downcase if row.header?(:visibility_status)

        was_new_record = country.new_record?
        any_changes = country.changed?

        country.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      ASCOR::Country
    end

    def required_headers
      [:id]
    end

    def prepare_country(row)
      find_record_by(:id, row) ||
        find_record_by(:iso, row, column_name: :country_iso_code) ||
        resource_klass.new
    end
  end
end
