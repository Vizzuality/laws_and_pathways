module TPI
  module StaticPagesController
    extend ActiveSupport::Concern

    included do
      before_action :static_pages
    end

    def static_pages
      @tpi_tool_pages = Page.where(menu: 'tpi_tool')
      @about_pages = Page.where(menu: 'about')
    end
  end
end
