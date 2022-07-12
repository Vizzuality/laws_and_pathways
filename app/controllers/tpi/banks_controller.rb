module TPI
  class BanksController < TPIController
    before_action :fetch_bank, only: [:show, :assessment]
    before_action :fetch_banks
    before_action :redirect_if_numeric_or_historic_slug, only: [:show]
    before_action :fetch_assessment, only: [:show, :assessment]

    helper_method :child_indicators

    def index
      @banks = Bank.all
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
