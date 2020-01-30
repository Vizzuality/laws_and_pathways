module CCLOW
  class HomeController < CCLOWController
    def index
      @latest_additions = ::Api::LatestAdditions.new(5).call
      @featured_countries = ::Geography.where(name: ['China', 'United States',
                                                     'European Union', 'India',
                                                     'Indonesia'])
      @link = admin_root_path
      @admin_panel_section_title = 'Dashboard'
    end

    def sandbox; end
  end
end
