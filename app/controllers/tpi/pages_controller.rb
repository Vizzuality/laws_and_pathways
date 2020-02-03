module TPI
  class PagesController < TPIController
    def show
      @page = TPIPage.find(params[:id])

      fixed_navbar("Page #{@page.title}", admin_tpi_page_path(@page))

      redirect_to '' unless @page
    end
  end
end
