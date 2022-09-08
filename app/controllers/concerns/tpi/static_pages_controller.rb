module TPI
  module StaticPagesController
    extend ActiveSupport::Concern

    included do
      before_action :static_pages
    end

    def static_pages
      @tpi_tool_pages = TPIPage.where(menu: 'tpi_tool').order(:position).map(&:to_menu_entry)
      @tpi_tool_pages_paths = @tpi_tool_pages.map { |p| p[:path] }
      @about_pages = TPIPage.where(menu: 'about').order(:position).map(&:to_menu_entry)
      @about_tpi_centre = TPIPage.where(menu: 'about_tpi_centre').order(:position).map(&:to_menu_entry)
      @about_tpi_ltd = TPIPage.where(menu: 'about_tpi_ltd').order(:position).map(&:to_menu_entry)
      @about_pages_paths = (@about_pages + @about_tpi_centre + @about_tpi_ltd).map { |p| p[:path] }
    end
  end
end
