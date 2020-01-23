module TPI
  class PagesController < TPIController
    def show
      @page = TPIPage.find(params[:id])
      redirect_to '' unless @page
    end
  end
end
