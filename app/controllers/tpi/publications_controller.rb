module TPI
  class PublicationsController < TPIController
    before_action :fetch_tags, only: [:index]
    before_action :fetch_sectors, only: [:index]

    def index
      @publications_and_articles = Queries::TPI::NewsPublicationsQuery
        .new(filter_params).call
    end

    def partial
      @publications_and_articles = Queries::TPI::NewsPublicationsQuery.new(filter_params).call

      render partial: 'promoted'
    end

    def show
      @publication = params[:type].eql?('NewsArticle') ? NewsArticle.find(params[:id]) : Publication.find(params[:id])
      redirect_to '' unless @publication
    end

    private

    def filter_params
      params.permit(:tags, :sectors)
    end

    def fetch_tags
      @tags = Keyword
        .joins(:taggings)
        .where(taggings: {taggable_type: %w(NewsArticle Publication)})
        .distinct
        .pluck(:name)
    end

    def fetch_sectors
      @sectors = (Publication.joins(:sector).select('tpi_sectors.name as sector_name').map(&:sector_name) +
       NewsArticle.joins(:sector).select('tpi_sectors.name as sector_name').map(&:sector_name)).uniq
    end
  end
end
