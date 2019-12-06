module CCLOW
  module StaticPagesController
    extend ActiveSupport::Concern

    included do
      before_action :static_pages
    end

    def static_pages
      @header_pages = CCLOWPage.header.map do |p|
        {slug: p.slug_path, title: p.title}
      end
      @footer_pages = CCLOWPage.footer.map do |p|
        {slug: p.slug_path, title: p.title}
      end
      @both = CCLOWPage.both.map do |p|
        {slug: p.slug_path, title: p.title}
      end
    end
  end
end
