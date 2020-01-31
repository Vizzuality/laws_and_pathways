module TPI
  class TPIController < ApplicationController
    include StaticPagesController

    layout 'tpi'

    protected

    def fixed_navbar(admin_panel_section_title, admin_panel_link)
      @admin_panel_section_title = admin_panel_section_title
      @link = admin_panel_link
    end
  end
end
