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

      @partners_logos = TPIPage.find_by(slug: 'research-funding-partners')&.contents&.flat_map(&:images)

      publications = Publication.where.not(publication_date: nil)
        .order(publication_date: :desc).limit(3)
      news = NewsArticle.where.not(publication_date: nil)
        .order(publication_date: :desc).limit(3)

      @publications_and_articles = (publications + news)
        .sort { |a, b| b.publication_date <=> a.publication_date }[0, 3]

      @home_content = TPTIPage.find_by(slug: 'home')

      fixed_navbar('Dashboard', admin_root_path)
    end

    def sandbox; end

    def newsletter; end

    def register; end

    def disclaimer; end
  end
end
