module TPI
  class HomeController < TPIController
    def index
      @testimonials = Testimonial.all.map do |test|
        {
          author: test.author,
          role: test.role,
          message: [test.quote],
          avatar_url: (url_for(test.avatar) if test.avatar.present?)
        }
      end

      @partners_logos = Page.find_by(slug: 'supporters')&.contents&.find_by(content_type: 'partners')&.images
    end

    def about; end

    def sandbox; end

    def newsletter; end
  end
end
