module TPI
  class ASCORController < TPIController
    before_action :fetch_ascor_countries, only: [:index, :show]
    before_action :fetch_ascor_country, only: [:show]

    def index
      @assessment_dates = ASCOR::Assessment.pluck(:assessment_date).uniq
      @publications_and_articles = TPISector.find_by(slug: 'ascor')&.publications_and_articles || []
      ascor_page = TPIPage.find_by(slug: 'ascor')
      @methodology_description = Content.find_by(page: ascor_page, code: 'methodology_description')
      @methodology_id = Content.find_by(page: ascor_page, code: 'methodology_publication_id')
      @methodology_publication = Publication.find_by(id: @methodology_id&.text)

      fixed_navbar('ASCOR Countries', admin_ascor_countries_path)
    end

    def show
      fixed_navbar("ASCOR Country #{@country.name}", admin_ascor_country_path(@country.id))
    end

    def user_download
      render zip: {
        'ASCOR_countries.xlsx' => Api::CSVToExcel.new(CSVExport::ASCOR::Countries.new.call).call,
        'ASCOR_indicators.xlsx' => Api::CSVToExcel.new(CSVExport::ASCOR::AssessmentIndicators.new.call).call,
        'ASCOR_assessments_results.xlsx' => Api::CSVToExcel.new(CSVExport::ASCOR::Assessments.new.call).call
      }, filename: "TPI ASCOR data - #{Time.now.strftime('%d%m%Y')}"
    end

    private

    def fetch_ascor_countries
      @countries = ASCOR::Country.all.order(:name)
      @countries_json = @countries.map { |s| s.as_json(except: [:created_at, :updated_at], methods: [:path]) }
    end

    def fetch_ascor_country
      @country = ASCOR::Country.friendly.find(params[:id])
    end
  end
end
