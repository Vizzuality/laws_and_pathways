module CCLOW
  class CCLOWController < ApplicationController
    include StaticPagesController

    layout 'cclow'

    protected

    def add_breadcrumb(title, path)
      @breadcrumb = (@breadcrumb || []).push(Site::Breadcrumb.new(title, path))
    end

    def fixed_navbar(admin_panel_section_title, admin_panel_link)
      @admin_panel_section_title = admin_panel_section_title
      @link = admin_panel_link
    end
  end
end
