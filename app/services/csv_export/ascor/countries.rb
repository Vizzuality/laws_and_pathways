module CSVExport
  module ASCOR
    class Countries
      HEADERS = [
        'Id',
        'Name',
        'Country ISO code',
        'Region',
        'World Bank lending group',
        'International Monetary Fund fiscal monitor category',
        'Type of Party to the United Nations Framework Convention on Climate Change'
      ].freeze

      def call
        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << HEADERS

          countries.each do |country|
            csv << [
              country.id,
              country.name,
              country.iso,
              country.region,
              country.wb_lending_group,
              country.fiscal_monitor_category,
              country.type_of_party
            ]
          end
        end
      end

      private

      def countries
        @countries ||= ::ASCOR::Country.published.order(:name)
      end
    end
  end
end
