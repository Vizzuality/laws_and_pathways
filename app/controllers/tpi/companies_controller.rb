module TPI
  class CompaniesController < TPIController
    before_action :fetch_company

    def show
      @company_summary = company_presenter.summary
      @mq_assessment = if params[:mq_assessment_id].present?
                         @company.mq_assessments.find(params[:mq_assessment_id])
                       else
                         @company.latest_mq_assessment
                       end
      @cp_assessment = if params[:cp_assessment_id].present?
                         @company.cp_assessments.find(params[:cp_assessment_id])
                       else
                         @company.latest_cp_assessment
                       end
    end

    def mq_assessment
      mq_assessment = @company.mq_assessments.find(params[:mq_assessment_id])

      render partial: 'mq_assessment', locals: {assessment: mq_assessment}
    end

    def cp_assessment
      @cp_assessment = @company.cp_assessments.find(params[:cp_assessment_id])

      # render partial: 'cp_assessment', locals: {assessment: cp_assessment}
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
      @assessment = CP::Assessment.find(params[:cp_assessment_id])
      data = ::Api::Charts::CPAssessment.new(@assessment).emissions_data

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
