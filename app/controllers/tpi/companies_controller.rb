module TPI
  class CompaniesController < TPIController
    before_action :fetch_company

    def show
      @company_summary = company_presenter.summary
      @mq_assessment = if params[:mq_assessment].present?
                         @company.mq_assessment.find(params[:mq_assessment])
                       else
                         @company.latest_mq_assessment
                       end
      @company_mq_assessments = company_presenter.mq_assessments
    end

    def mq_assessment
      mq_assessment = @company.mq_assessments.find(params[:mq_assessment])

      render partial: 'mq_assessment', locals: {
               mq_assessment: mq_assessment,
               levels_descriptions: Api::Presenters::Company::SECTORS_LEVELS_DESC
             }
    end

    # Data:     Company MQ Assessments Levels over the years
    # Section:  MQ
    # Type:     line chart
    # On pages: :show
    def assessments_levels_chart_data
      data = ::Api::Charts::Company.new(@company).assessments_levels_data

      render json: data.chart_json
    end

    # Data:     Company emissions
    # Section:  CP
    # Type:     line chart
    # On pages: :show
    def emissions_chart_data
      data = ::Api::Charts::Company.new(@company).emissions_data

      render json: data.chart_json
    end

    private

    def company_presenter
      @company_presenter ||= ::Api::Presenters::Company.new(@company)
    end

    def fetch_company
      @company = Company.friendly.find(params[:id])
    end
  end
end
