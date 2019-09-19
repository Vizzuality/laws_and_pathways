module Api
  module Companies
    class Emissions
      def initialize(company)
        @company = company
      end

      def get
        [
          {
            name: @company.name,
            data: company_emissions
          },
          {
            name: "#{@company.sector.name} sector mean",
            data: company_sector_mean_emissions
          }
        ]
      end

      private

      def company_emissions
        {
          2012 => 111.0, 2013 => 112.0,
          2014 => 101.0, 2015 => 104.0,
          2016 => 102.0, 2017 => 95.0,
          2018 => 96.0, 2019 => 92.0,
          2020 => 90.0, 2021 => 85.0,
          2022 => 83.0, 2023 => 80.0
        }
      end

      def company_sector_mean_emissions
        {
          2014 => 96.0, 2015 => 94.0,
          2016 => 93.0, 2017 => 90.0,
          2018 => 86.0, 2019 => 82.0,
          2020 => 81.0, 2021 => 75.0,
          2022 => 73.0, 2023 => 70.0
        }
      end
    end
  end
end
