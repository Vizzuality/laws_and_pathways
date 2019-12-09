class CCLOWMapContentData
  class << self
    def all
      [
        number_of_climate_laws_and_policies,
        number_of_climate_lawsuits
      ]
    end

    def number_of_climate_laws_and_policies
      result = Geography.published
        .joins(:legislations)
        .where(legislations: {visibility_status: ::Legislation.visibility_statuses[:published]})
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
        legend_description: <<-TEXT,
        The <b>size</b> of the circle represents the number of climate laws and policies. The larger the circle, the higher the number of climate laws and policies.
        TEXT
        creator: {
          name: 'Grantham Research Institute',
          url: 'http://www.lse.ac.uk/granthamInstitute'
        },
        values: result
      }
    end

    def number_of_climate_lawsuits
      result = Geography.published
        .joins(:litigations)
        .where(litigations: {visibility_status: Litigation.visibility_statuses[:published]})
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
        name: 'Number of Litigation Cases',
        legend_description: <<-TEXT,
        The <b>size</b> of the circle represents the number of climate lawsuits. The larger the circle, the higher the number of climate lawsuits.
        TEXT
        creator: {
          name: 'Grantham Research Institute',
          url: url.cclow_root_path
        },
        values: result
      }
    end

    def url
      Rails.application.routes.url_helpers
    end
  end
end
