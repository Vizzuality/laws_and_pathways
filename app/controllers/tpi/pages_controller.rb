module TPI
  class PagesController < TPIController
    def show
      @page = Page.find(params[:id])
      redirect_to '' unless @page
    end
  end
end
