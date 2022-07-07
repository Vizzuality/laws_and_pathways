module TPI
  class BanksController < TPIController
    before_action :fetch_bank, only: [:show]
    before_action :fetch_banks
    before_action :redirect_if_numeric_or_historic_slug, only: [:show]

    def index
      @banks = Bank.all
    end

    def show
      fixed_navbar(
        "Bank #{@bank.name}",
        admin_bank_path(@bank)
      )
    end

    private

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
