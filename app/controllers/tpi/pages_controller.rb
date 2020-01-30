module TPI
  class PagesController < TPIController
    def show
      @page = TPIPage.find(params[:id])

      @admin_panel_section_title = "Page #{@page.title}"
      @link = admin_tpi_page_path(@page)

      redirect_to '' unless @page
    end
  end
end
