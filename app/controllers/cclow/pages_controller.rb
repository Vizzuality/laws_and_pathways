module CCLOW
  class PagesController < CCLOWController
    def show
      @page = CCLOWPage.find(params[:id])
      redirect_to '' unless @page
    end
  end
end
