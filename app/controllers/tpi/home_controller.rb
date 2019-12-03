module TPI
  class HomeController < TPIController
    def index
      @testimonials = Testimonial.all.map do |test|
        {
          author: test.author,
          role: test.role,
          message: [test.quote]
        }
      end

      @partners_logos = Page.find_by(slug: 'supporters')&.contents&.find_by(content_type: 'partners')&.images

      publications = Publication.all.sort_by(&:created_at)
      news = NewsArticle.all.sort_by(&:created_at)

      @publications_and_articles = publications + news
    end

    def about; end
    def sandbox; end
    def newsletter; end
    def register; end
  end
end
