module TPI
  module StaticPagesController
    extend ActiveSupport::Concern

    included do
      before_action :static_pages
    end

    def static_pages
      @tpi_tool_pages = TPIPage.where(menu: 'tpi_tool').map do |p|
        {path: p.path, title: p.title}
      end
      @tpi_tool_pages_paths = @tpi_tool_pages.map { |p| p[:path] }
      @about_pages = TPIPage.where(menu: 'about').map do |p|
        {path: p.path, title: p.title}
      end
      @about_pages_paths = @about_pages.map { |p| p[:path] }
    end
  end
end
