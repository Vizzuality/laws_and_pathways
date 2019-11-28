module TPI
  module StaticPagesController
    extend ActiveSupport::Concern

    included do
      before_action :get_pages
    end

    def get_pages
      @tpi_tool_pages = Page.where(menu: "tpi_tool")
      @about_pages = Page.where(menu: "about")
    end
  end
end