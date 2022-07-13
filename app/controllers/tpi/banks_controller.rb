module TPI
  class BanksController < TPIController
    before_action :fetch_bank, only: [:show, :assessment]
    before_action :fetch_banks, only: [:index, :show]
    before_action :redirect_if_numeric_or_historic_slug, only: [:show]
    before_action :fetch_assessment, only: [:show, :assessment]

    helper_method :child_indicators

    def index
      @results = BankAssessmentResult
        .of_type(:area)
        .includes(assessment: :bank)
        .map do |result|
          {
            area: result.indicator.display_text,
            percentage: result.percentage,
            bank_id: result.assessment.bank_id,
            bank_name: result.assessment.bank.name,
            bank_path: tpi_bank_path(result.assessment.bank_id),
            market_cap_group: result.assessment.bank.market_cap_group
          }
        end
    end

    def show
      fixed_navbar(
        "Bank #{@bank.name}",
        admin_bank_path(@bank)
      )
    end

    def assessment; end

    def average_bank_score_chart_data
      data = ::Api::Charts::AverageBankScore.new.average_bank_score_data

      render json: data.chart_json
    end

    private

    def fetch_bank
      @bank = Bank.friendly.find(params[:id])
    end

    def fetch_banks
      @banks = Bank.all
      @banks_json = [
        {name: 'All banks', path: tpi_banks_path},
        *@banks.as_json(only: [:name], methods: [:path])
      ]
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
