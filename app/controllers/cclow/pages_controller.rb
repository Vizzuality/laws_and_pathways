module CCLOW
  class PagesController < CCLOWController
    def show
      @page = PageDecorator.decorate(CCLOWPage.find(params[:id]))

      @breadcrumb = [
        Site::Breadcrumb.new('Home', cclow_root_path),
        Site::Breadcrumb.new(@page.title, @page.slug_path)
      ]

      redirect_to '' unless @page
    end
  end
end
