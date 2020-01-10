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

      @partners_logos = TPIPage.find_by(slug: 'supporters')&.contents&.find_by(content_type: 'partners')&.images

      publications = Publication.order(publication_date: :desc).limit(3)
      news = NewsArticle.order(publication_date: :desc).limit(3)

      @publications_and_articles = (publications + news)
        .sort { |a, b| b.publication_date <=> a.publication_date }[0, 3]
    end

    def sandbox; end

    def newsletter; end

    def register; end

    def disclaimer; end
  end
end
