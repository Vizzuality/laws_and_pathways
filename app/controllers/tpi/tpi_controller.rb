module TPI
  class TPIController < ApplicationController
    include StaticPagesController

    layout 'tpi'

    protected

    def enable_beta_mq_assessments
      session[:enable_beta_mq_assessments] = true unless session.key?(:enable_beta_mq_assessments)
    end

    def fixed_navbar(admin_panel_section_title, admin_panel_link)
      @admin_panel_section_title = admin_panel_section_title
      @link = admin_panel_link
    end
  end
end
