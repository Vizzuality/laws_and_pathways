module CCLOW
  class SitemapsController < CCLOWController
    def index
      @host = "https://#{request.host_with_port}"
      @geographies = ::Geography.published.select(:id, :slug)
      @laws_by_geo_id = Legislation.laws.published.select(:id, :slug, :geography_id).group_by(&:geography_id)
      @policies_by_geo_id = Legislation.policies.published.select(:id, :slug, :geography_id).group_by(&:geography_id)
      @cases_by_geo_id = Litigation.published.select(:id, :slug, :geography_id).group_by(&:geography_id)
      @target_sectors_by_geo_id = Target
        .published
        .joins(:sector)
        .select('DISTINCT laws_sectors.name as sector_name, geography_id')
        .order(:sector_name)
        .group_by(&:geography_id)
    end
  end
end
