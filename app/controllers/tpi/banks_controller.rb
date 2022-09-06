module TPI
  class BanksController < TPIController
    before_action :fetch_bank, only: [:show, :assessment]
    before_action :fetch_banks, only: [:index, :show]
    before_action :redirect_if_numeric_or_historic_slug, only: [:show]
    before_action :fetch_assessment, only: [:show, :assessment]
    before_action :fetch_results, only: [:index, :index_assessment]

    helper_method :child_indicators

    def index
      @assessment_dates = BankAssessment.select(:assessment_date).distinct.pluck(:assessment_date)
      @publications_and_articles = TPISector.find_by(slug: 'banks')&.publications_and_articles || []
      bank_page = TPIPage.find_by(slug: 'banks-content')
      @methodology_description = Content.find_by(
        page: bank_page,
        code: 'methodology_description'
      )
      @methodology_id = Content.find_by(
        page: bank_page,
        code: 'methodology_publication_id'
      )
      @methodology_publication = Publication.find_by(id: @methodology_id&.text)

      fixed_navbar('Banks', admin_banks_path)
    end

    def show
      fixed_navbar(
        "Bank #{@bank.name}",
        admin_bank_path(@bank)
      )
    end

    def index_assessment; end

    def assessment; end

    def average_bank_score_chart_data
      data = ::Api::Charts::AverageBankScore.new.average_bank_score_data

      render json: data.chart_json
    end

    def user_download
      timestamp = Time.now.strftime('%d%m%Y')

      bank_assessment_indicators_csv = CSVExport::User::BankAssessmentIndicators.new.call
      bank_assessments_csv = CSVExport::User::BankAssessments.new.call

      render zip: {
        'Framework of pilot indicators.csv' => bank_assessment_indicators_csv,
        "Bank assessments #{timestamp}.csv" => bank_assessments_csv
      }, filename: "TPI banking data - #{timestamp}"
    end

    private

    def fetch_bank
      @bank = Bank.friendly.find(params[:id])
    end

    def fetch_banks
      @banks = Bank.order('lower(name)')
      @banks_json = [
        {name: 'All banks', path: tpi_banks_path},
        *@banks.as_json(only: [:name], methods: [:path])
      ]
    end

    def fetch_results
      @date = params[:assessment_date]
      @date = BankAssessment.maximum(:assessment_date) unless @date.present?
      @results = BankAssessmentResult
        .by_date(@date)
        .of_type(:area)
        .includes(assessment: :bank)
        .order(:number)
        .map do |result|
          {
            area: result.indicator.text,
            percentage: result.percentage,
            bank_id: result.assessment.bank_id,
            bank_name: result.assessment.bank.name,
            bank_path: tpi_bank_path(result.assessment.bank_id),
            market_cap_group: result.assessment.bank.market_cap_group
          }
        end
    end

    def fetch_assessment
      @assessment = if params[:assessment_id].present?
                      @bank.assessments.find(params[:assessment_id])
                    else
                      @bank.latest_assessment
                    end
      @assessment_presenter = BankAssessmentPresenter.new(@assessment)
    end

    def redirect_if_numeric_or_historic_slug
      redirect_to tpi_bank_path(@bank.slug), status: :moved_permanently if params[:id] != @bank.slug
    end
  end
end
