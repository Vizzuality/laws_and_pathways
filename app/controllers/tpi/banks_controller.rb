module TPI
  class BanksController < TPIController
    before_action :fetch_bank, only: [:show]
    before_action :fetch_banks
    before_action :redirect_if_numeric_or_historic_slug, only: [:show]

    helper_method :child_indicators

    def index
      @banks = Bank.all
    end

    def show
      @results_by_indicator_type = @bank.assessments.last&.results_by_indicator_type

      fixed_navbar(
        "Bank #{@bank.name}",
        admin_bank_path(@bank)
      )
    end

    private

    def child_indicators(result, indicator_type)
      @results_by_indicator_type[indicator_type].select { |r| r.indicator.number.start_with?(result.indicator.number) }
    end

    def fetch_bank
      @bank = Bank.friendly.find(params[:id])
    end

    def fetch_banks
      @banks = Bank.all
    end

    def redirect_if_numeric_or_historic_slug
      redirect_to tpi_bank_path(@bank.slug), status: :moved_permanently if params[:id] != @bank.slug
    end
  end
end
