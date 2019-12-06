class CCLOWMapContentData
  class << self
    def all
      [
        number_of_climate_laws_and_policies,
        number_of_climate_lawsuits
      ]
    end

    def number_of_climate_laws_and_policies
      result = Geography
        .joins(:legislations)
        .group(:iso)
        .pluck('iso, count(*) as count')
        .map do |data|
          {
            geography_iso: data[0],
            value: data[1]
          }
        end

      {
        id: :number_of_climate_laws_and_policies,
        name: 'Number of Climate Laws and Policies',
        values: result
      }
    end

    def number_of_climate_lawsuits
      result = Geography
        .joins(:litigations)
        .group(:iso)
        .pluck('iso, count(*) as count')
        .map do |data|
        {
          geography_iso: data[0],
          value: data[1]
        }
      end

      {
        id: :number_of_climate_lawsuits,
        name: 'Number of Climate Lawsuits',
        values: result
      }
    end
  end
end
