module TPI
  class MQAssessmentsController < TPIController
    def show; end

    def enable_beta_data
      session[:enable_beta_mq_assessments] = true

      redirect_to redirect_back_path
    end

    def disable_beta_data
      session[:enable_beta_mq_assessments] = false

      redirect_to redirect_back_path
    end

    private

    def redirect_back_path
      return tpi_root_url unless request.referer.present?

      URI(request.referer).path
    end
  end
end
