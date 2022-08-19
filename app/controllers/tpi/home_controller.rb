module TPI
  class HomeController < TPIController
    def index
      @testimonials = Testimonial.all.map do |test|
        {
          author: test.author,
          role: test.role,
          message: test.quote
        }
      end

      @stats = {
        companies_count: Company.published.count,
        countries_count: Company.select(:geography_id).distinct.count,
        supporters_count: TPIPage.find_by(slug: 'supporters')&.contents&.flat_map(&:images)&.count
      }
      @sector_clusters = TPISectorCluster.all.group_by(&:slug).transform_values(&:first)

      @publications_and_articles = publications_and_articles
      @home_content = home_content

      fixed_navbar('Dashboard', admin_root_path)
    end

    def sandbox; end

    def newsletter; end

    def disclaimer; end

    private

    def publications_and_articles
      publications = Publication.published.order(publication_date: :desc).limit(3)
      news = NewsArticle.published.order(publication_date: :desc).limit(3)

      (publications + news).sort do |a, b|
        b.publication_date <=> a.publication_date
      end.first(3)
    end

    def home_content
      contents = Content.joins(:page).where(pages: {slug: 'homepage-content'})
        .order(:created_at).to_a
      {
        intro: {
          title: contents&.first&.title || 'The TPI tool',
          description: ActionView::Base.full_sanitizer.sanitize(contents&.first&.text) ||
            'The Transition Pathway Initiative (TPI) is a global, asset-owner led
              initiative which assesses companies\' preparedness for the transition to
              a low carbon economy. Rapidly becoming the go-to corporate climate action benchmark,
              the TPI tool is available here.'
        },
        investors: {
          title: contents&.second&.title || 'How investors can use the TPI',
          description: ActionView::Base.full_sanitizer.sanitize(contents&.second&.text) ||
            'The TPI is designed to support investors. Find out how they can use its findings.'
        },
        supporters: {
          title: contents&.third&.title || 'Supporters',
          description: ActionView::Base.full_sanitizer.sanitize(contents&.third&.text) ||
            'The TPI is supported globally by more than 75 investors with over
              $20.5 trillion combined Assets Under Management and Advice.'
        }
      }
    end
  end
end
