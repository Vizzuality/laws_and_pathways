module TPI
  class PublicationsController < TPIController
    before_action :fetch_tags, only: [:index]
    before_action :fetch_sectors, only: [:index]

    def index
      @publications_and_articles = Queries::TPI::NewsPublicationsQuery
        .new(filter_params).call

      @admin_panel_section_title = 'Publications'
      @link = admin_publications_path
    end

    def partial
      @publications_and_articles = Queries::TPI::NewsPublicationsQuery.new(filter_params).call

      render partial: 'promoted'
    end

    def show
      @publication = params[:type].eql?('NewsArticle') ? NewsArticle.find(params[:id]) : Publication.find(params[:id])
      respond_to do |format|
        format.html
        format.pdf { redirect_to rails_blob_url(@publication.file, disposition: 'preview') }
      end
      @admin_panel_section_title = "Publication #{@publication.title}"
      @link = admin_publication_path(@publication)
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
      @sectors = (Publication.joins(:tpi_sectors).select('tpi_sectors.name as sector_name').map(&:sector_name) +
       NewsArticle.joins(:tpi_sectors).select('tpi_sectors.name as sector_name').map(&:sector_name)).uniq
    end
  end
end
