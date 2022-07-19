module CSVImport
  class Banks < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        bank = prepare_bank(row)

        bank.name = row[:name] if row.header?(:name)
        bank.isin = row[:isins] if row.header?(:isins)
        bank.market_cap_group = row[:market_cap_group].downcase if row.header?(:market_cap_group)
        bank.sedol = row[:sedol].presence if row.header?(:sedol)
        bank.geography = find_geography(row[:geography_iso]) if row.header?(:geography_iso)
        bank.latest_information = row[:latest_information] if row.header?(:latest_information)

        was_new_record = bank.new_record?
        any_changes = bank.changed?

        bank.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Bank
    end

    def required_headers
      [:id]
    end

    def prepare_bank(row)
      return prepare_overridden_resource(row) if override_id

      find_record_by(:id, row) ||
        find_record_by(:name, row) ||
        resource_klass.new
    end
  end
end
