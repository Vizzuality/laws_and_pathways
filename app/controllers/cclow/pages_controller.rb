module CCLOW
  class PagesController < CCLOWController
    def show
      @page = CCLOWPage.find(params[:id])

      @breadcrumb = [
        Site::Breadcrumb.new('Home', cclow_root_path),
        Site::Breadcrumb.new(@page.title, @page.slug_path)
      ]

      fixed_navbar(@page.title, admin_cclow_page_path(@page))

      redirect_to '' unless @page
    end
  end
end
