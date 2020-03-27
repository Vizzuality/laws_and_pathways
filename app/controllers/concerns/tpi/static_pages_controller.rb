module TPI
  module StaticPagesController
    extend ActiveSupport::Concern

    included do
      before_action :static_pages
    end

    def static_pages
      @tpi_tool_pages = TPIPage.where(menu: 'tpi_tool')
      @tpi_tool_pages_paths = @tpi_tool_pages.map(&:path)
      @about_pages = TPIPage.where(menu: 'about')
      @about_pages_paths = @about_pages.map(&:path)
    end
  end
end
