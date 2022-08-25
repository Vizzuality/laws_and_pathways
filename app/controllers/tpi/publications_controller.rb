module TPI
  class PublicationsController < TPIController
    include ActionController::Live

    before_action :fetch_tags, only: [:index]
    before_action :fetch_sectors, only: [:index]
    before_action :fetch_publication, only: [:show]

    def index
      results = Queries::TPI::NewsPublicationsQuery.new(filter_params).call
      @publications_and_articles_count = results.size
      @publications_and_articles = results.drop(offset).take(9)

      fixed_navbar('Publications', admin_publications_path)
    end

    def partial
      results = Queries::TPI::NewsPublicationsQuery.new(filter_params).call
      @publications_and_articles = results.drop(offset).take(9)

      if offset.positive?
        render partial: 'list', locals: {
          publications_and_articles: @publications_and_articles
        }
      else
        render partial: 'promoted', locals: {
          publications_and_articles: @publications_and_articles,
          count: results.count
        }
      end
    end

    def show
      respond_to do |format|
        format.html do
          admin_panel_path = polymorphic_path([:admin, @publication])
          fixed_navbar("#{@publication.class.name.underscore.humanize} #{@publication.title}", admin_panel_path)

          redirect_to '' unless @publication
        end
        format.pdf { stream_publication_file }
      end
    end

    private

    def stream_publication_file
      send_file_headers!(
        type: @publication.file.content_type,
        disposition: 'inline',
        filename: @publication.file.filename.to_s
      )

      @publication.file.download do |chunk|
        response.stream.write(chunk)
      end
    ensure
      response.stream.close
    end

    def offset
      params[:offset]&.to_i || 0
    end

    def filter_params
      params.permit(:tags, :sectors)
    end

    def fetch_publication
      @publication = if params[:type].eql?('NewsArticle')
                       NewsArticle.published.find(params[:id])
                     else
                       Publication.published.find(params[:id])
                     end
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
