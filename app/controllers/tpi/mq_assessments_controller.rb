module TPI
  class MQAssessmentsController < TPIController
    def show; end

    def enable_beta_data
      session[:enable_beta_mq_assessments] = true

      redirect_back fallback_location: tpi_root_url
    end

    def disable_beta_data
      session[:enable_beta_mq_assessments] = false

      redirect_back fallback_location: tpi_root_url
    end
  end
end
