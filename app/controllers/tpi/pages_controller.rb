module TPI
  class PagesController < TPIController
    def show
      @page = PageDecorator.decorate(TPIPage.find(params[:id]))
      redirect_to '' unless @page
    end
  end
end
