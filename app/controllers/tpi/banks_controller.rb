module TPI
  class BanksController < TPIController
    before_action :fetch_bank, only: [:show, :assessment, :emissions_chart_data, :cp_matrix_data]
    before_action :fetch_banks, only: [:index, :show]
    before_action :redirect_if_numeric_or_historic_slug, only: [:show]
    before_action :fetch_assessment, only: [:show, :assessment]
    before_action :fetch_cp_assessment, only: [:show, :emissions_chart_data]
    before_action :fetch_results, only: [:index, :index_assessment]

    helper_method :child_indicators

    def index
      @assessment_dates = BankAssessment.dates_with_data
      @publications_and_articles = TPISector.find_by(slug: 'banks')&.publications_and_articles || []
      @publications_and_articles = @publications_and_articles.select { |pa| pa.publication_date <= Time.current }
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
      data = ::Api::Charts::AverageBankScore.new.average_bank_score_data(params[:assessment_date])

      render json: data.chart_json
    end

    def user_download
      timestamp = Time.now.strftime('%d%m%Y')

      bank_assessment_indicators_csv = CSVExport::User::BankAssessmentIndicators.new.call
      bank_assessments_csv = CSVExport::User::BankAssessments.new.call

      render zip: {
        'Framework of pilot indicators.xlsx' => Api::CSVToExcel.new(bank_assessment_indicators_csv).call,
        "Bank assessments #{timestamp}.xlsx" => Api::CSVToExcel.new(bank_assessments_csv).call,
        "Bank CP assessments #{timestamp}.xlsx" => Api::CSVToExcel.new(CSVExport::User::BankCPAssessments.new.call).call
      }, filename: "TPI banking data - #{timestamp}"
    end

    # Data:     Bank emissions
    # Section:  CP
    # Type:     line chart
    # On pages: :show
    def emissions_chart_data
      data = ::Api::Charts::CPAssessment.new(@cp_assessment, 'regional').emissions_data

      render json: data.chart_json
    end

    # Data:     Bank CP Alignments
    # Section:  CP
    # Type:     table
    # On pages: :show
    def cp_matrix_data
      data = ::Api::Charts::CPMatrix.new(@bank, params[:cp_assessment_date]).matrix_data

      render json: data.as_json
    end

    def send_download_file_info_email
      DataDownloadMailer.send_download_file_info_email(
        permitted_email_params,
        'gri.banking@lse.ac.uk',
        'Banking data has been downloaded'
      ).deliver_now
      head :ok
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
      @date = BankAssessment.dates_with_data.first unless @date.present?
      @version = determine_version_for_date(@date)
      @results = BankAssessmentResult
        .by_date(@date)
        .of_type(:area)
        .with_version(@version)
        .includes(assessment: :bank)
        .order('length(bank_assessment_indicators.number), bank_assessment_indicators.number')
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
                      @bank.assessments_with_data.first
                    end

      # If no assessment exists, create a virtual one for display purposes
      @assessment = create_virtual_assessment if @assessment.nil?

      @assessment_presenter = BankAssessmentPresenter.new(@assessment)
    end

    def fetch_cp_assessment
      @cp_assessment = if params[:cp_assessment_id].present?
                         @bank.cp_assessments.find(params[:cp_assessment_id])
                       else
                         @bank.cp_assessments.where(sector_id: params[:sector_id]).currently_published
                           .order(assessment_date: :desc).first
                       end
    end

    def redirect_if_numeric_or_historic_slug
      redirect_to tpi_bank_path(@bank.slug), status: :moved_permanently if params[:id] != @bank.slug
    end

    def permitted_email_params
      params.permit(:email, :job_title, :forename, :surname, :location, :organisation, :other_purpose, purposes: [])
    end

    def create_virtual_assessment
      # Create a virtual assessment object for banks without assessments
      # This allows the view to display the framework structure with empty indicators
      virtual_assessment = OpenStruct.new(
        id: "virtual_#{@bank.id}",
        bank: @bank,
        assessment_date: Date.current,
        notes: nil,
        indicator_version: '2025' # Use latest version for virtual assessments
      )

      # Create a virtual results object that responds to of_type method
      virtual_results = OpenStruct.new

      # Create a chainable empty result set
      empty_result_set = OpenStruct.new
      empty_result_set.define_singleton_method(:order) { |*_args| self }
      empty_result_set.define_singleton_method(:find) { nil }
      empty_result_set.define_singleton_method(:empty?) { true }
      empty_result_set.define_singleton_method(:any?) { false }
      empty_result_set.define_singleton_method(:length) { 0 }
      empty_result_set.define_singleton_method(:count) { 0 }

      virtual_results.define_singleton_method(:of_type) { |_type| empty_result_set }
      virtual_results.define_singleton_method(:order) { |*_args| self }
      virtual_results.define_singleton_method(:find) { nil }
      virtual_results.define_singleton_method(:empty?) { true }
      virtual_results.define_singleton_method(:any?) { false }

      virtual_assessment.results = virtual_results

      # Add methods that the presenter expects
      virtual_assessment.define_singleton_method(:results_by_indicator_type) { {} }
      virtual_assessment.define_singleton_method(:all_results_by_indicator_type) { {} }
      virtual_assessment.define_singleton_method(:active_results?) { false }
      virtual_assessment.define_singleton_method(:legacy_results?) { false }
      virtual_assessment.define_singleton_method(:child_indicators) { |_result, _type| [] }
      virtual_assessment.define_singleton_method(:virtual?) { true }

      virtual_assessment
    end

    def determine_version_for_date(date)
      return '2024' if date.blank?

      # Convert string to Date if needed
      parsed_date = date.is_a?(String) ? Date.parse(date) : date
      return '2025' if parsed_date >= Date.new(2025, 1, 1)
      return '2024' if parsed_date >= Date.new(2024, 1, 1)

      '2024'
    end
  end
end
