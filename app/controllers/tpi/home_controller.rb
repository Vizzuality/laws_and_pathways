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
          supporters_count: TPIPage.find_by(slug: 'supporters')&.contents&.flat_map(&:images)&.count.to_i +
            page&.contents&.find_by(code: 'supporters_without_logo')&.text.to_i,
          total_market_cap: page&.contents&.find_by(code: 'total_market_cap')&.text || '-',
          combined_aum: page&.contents&.find_by(code: 'combined_aum')&.text || '-',
          corporate_management_quality: page&.contents&.find_by(code: 'corporate_management_quality')&.text || '-',
          corporate_carbon_performance: page&.contents&.find_by(code: 'corporate_carbon_performance')&.text || '-',
          sectors_count: TPISector.with_companies.count,
          ascor_countries: ASCOR::Country.published.count,
          banks: Bank.published.count
        }
      }
      @latest_researches = Publication
        .published
        .includes([:image_attachment, :author_image_attachment])
        .order(publication_date: :desc)
        .take(3)

      fixed_navbar('Dashboard', admin_root_path)
    end

    def sandbox; end

    def newsletter; end

    def corporate_bond_issuers; end
  end
end
