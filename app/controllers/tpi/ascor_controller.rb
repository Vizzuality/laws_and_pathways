module TPI
  class ASCORController < TPIController
    before_action :fetch_ascor_countries, only: [:index, :show]
    before_action :fetch_ascor_country, only: [:show, :show_assessment]
    before_action :fetch_assessment_date, only: [:index, :show, :index_assessment]
    before_action :fetch_emissions_assessment_date, only: [:index, :index_emissions_assessment, :emissions_chart_data]
    before_action :fetch_ascor_assessment_results, only: [:index, :index_assessment]

    def index
      @assessment_dates = ASCOR::Assessment.pluck(:assessment_date).uniq.compact.sort.reverse
      @publications_and_articles = (
        Publication.published.joins(:tags).includes(:tpi_sectors).where(tags: {name: 'ASCOR'}) +
        NewsArticle.published.joins(:tags).where(tags: {name: 'ASCOR'})
      ).uniq.sort_by(&:publication_date).reverse!.take(3)
      ascor_page = TPIPage.find_by(slug: 'ascor')
      @methodology_description = Content.find_by(page: ascor_page, code: 'methodology_description')
      @methodology_id = Content.find_by(page: ascor_page, code: 'methodology_publication_id')
      @methodology_publication = Publication.find_by(id: @methodology_id&.text)

      fixed_navbar('ASCOR Countries', admin_ascor_countries_path)
    end

    def show
      @assessment = ASCOR::Assessment.includes(results: :indicator).find_by country: @country, assessment_date: @assessment_date
      @recent_emissions = Api::ASCOR::RecentEmissions.new(@assessment_date, @country).call
      fixed_navbar("ASCOR Country #{@country.name}", admin_ascor_country_path(@country.id))
    end

    def index_assessment; end

    def index_emissions_assessment; end

    def show_assessment
      @assessment = @country.assessments.includes(results: :indicator).find params[:assessment_id]
      @assessment_date = @assessment.assessment_date
      @recent_emissions = Api::ASCOR::RecentEmissions.new(@assessment_date, @country).call
    end

    def emissions_chart_data
      data = ::Api::ASCOR::EmissionsChart.new(
        @emissions_assessment_date,
        params[:emissions_metric],
        params[:emissions_boundary],
        params[:country_ids]
      ).call

      render json: data
    end

    def user_download
      render zip: {
        'ASCOR_countries.xlsx' => Api::CSVToExcel.new(CSVExport::ASCOR::Countries.new.call).call,
        'ASCOR_indicators.xlsx' => Api::CSVToExcel.new(CSVExport::ASCOR::AssessmentIndicators.new.call).call,
        'ASCOR_assessments_results.xlsx' => Api::CSVToExcel.new(CSVExport::ASCOR::Assessments.new.call).call,
        'ASCOR_benchmarks.xlsx' => Api::CSVToExcel.new(CSVExport::ASCOR::Benchmarks.new.call).call,
        'ASCOR_assessments_results_trends_pathways.xlsx' => Api::CSVToExcel.new(CSVExport::ASCOR::Pathways.new.call).call
      }, filename: "TPI ASCOR data - #{Time.now.strftime('%d%m%Y')}"
    end

    def send_download_file_info_email
      DataDownloadMailer.send_download_file_info_email(
        permitted_email_params,
        'tpi.centre.ascor@lse.ac.uk',
        'ASCOR data has been downloaded'
      ).deliver_now
      head :ok
    end

    private

    def fetch_ascor_countries
      @countries = ASCOR::Country.published.all.order(:name)
      @countries_json = [
        {name: 'All countries', path: tpi_ascor_index_path},
        *@countries.as_json(only: [:name], methods: [:path])
      ]
    end

    def fetch_ascor_country
      @country = ASCOR::Country.published.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to tpi_ascor_index_path
    end

    def fetch_assessment_date
      @assessment_date = params[:assessment_date].present? ? Date.parse(params[:assessment_date]) : ASCOR::Assessment.maximum(:assessment_date)
    end

    def fetch_emissions_assessment_date
      @emissions_assessment_date = params[:emissions_assessment_date].present? ? Date.parse(params[:emissions_assessment_date]) : ASCOR::Assessment.maximum(:assessment_date)
    end

    def fetch_ascor_assessment_results
      @ascor_assessment_results = Api::ASCOR::BubbleChart.new(@assessment_date).call
    end

    def permitted_email_params
      params.permit(
        :email,
        :job_title,
        :forename,
        :surname,
        :location,
        :organisation,
        :organisation_type,
        :asset_owner_type,
        :organisation_type_other,
        :use_case,
        :use_case_description,
        :self_attestation
      )
    end
  end
end
