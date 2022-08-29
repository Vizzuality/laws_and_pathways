module TPI
  class HomeController < TPIController
    def index
      @case_studies = CaseStudy.all
      @sector_clusters = TPISectorCluster.all.group_by(&:slug).transform_values(&:first)

      page = TPIPage.find_by(slug: 'homepage-content')
      @home_content = {
        intro: {
          title: page&.contents&.find_by(code: 'hero')&.title || 'The TPI Global Climate Transition Centre',
          text: ActionView::Base.full_sanitizer.sanitize(page&.contents&.find_by(code: 'hero')&.text) ||
            'Transition Pathway Initiative (TPI) Global Climate Transition Centre is an authoritative,
             independent source of research and data into the progress being made by the financial and
             corporate world in making the transition to a low-carbon economy.'
        },
        stats: {
          companies_count: Company.published.count,
          countries_count: Company.select(:geography_id).distinct.count,
          supporters_count: TPIPage.find_by(slug: 'supporters')&.contents&.flat_map(&:images)&.count,
          total_market_cap: page&.contents&.find_by(code: 'total_market_cap')&.text || '-',
          combined_aum: page&.contents&.find_by(code: 'combined_aum')&.text || '-',
          sectors: page&.contents&.find_by(code: 'sectors')&.text || '-'
        }
      }
      @researchers = [
        {
          text: 'Valentin Julius Jahn on the CA100+ benchmark update',
          image: 'tpi/home/temp-research-image.png',
          author_image: 'tpi/home/temp-research-author.png'
        },
        {
          text: 'Nikolaus Hastreiter and Tess Sokol-Sachs on banking projects, Lorem ipsum dolor sit amet',
          image: 'tpi/home/temp-research-image.png',
          author_image: 'tpi/home/temp-research-author.png'
        },
        {
          text: 'Valentin Julius Jahn on the CA100+ benchmark update',
          image: 'tpi/home/temp-research-image.png',
          author_image: 'tpi/home/temp-research-author.png'
        },
        {
          text: 'Valentin Julius Jahn on the CA100+ benchmark update',
          image: 'tpi/home/temp-research-image.png',
          author_image: 'tpi/home/temp-research-author.png'
        }
      ]

      fixed_navbar('Dashboard', admin_root_path)
    end

    def sandbox; end

    def newsletter; end

    def disclaimer; end
  end
end
