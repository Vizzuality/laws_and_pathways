module TPI
  module StaticPagesController
    extend ActiveSupport::Concern

    included do
      before_action :static_pages
    end

    def static_pages
      @tpi_tool_pages = Page.where(menu: 'tpi_tool').map do |t|
        {slug: t.slug_path, title: t.title}
      end
      @about_pages = Page.where(menu: 'about').map do |t|
        {slug: t.slug_path, title: t.title}
      end
    end
  end
end
