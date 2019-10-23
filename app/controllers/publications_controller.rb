class PublicationsController < InheritedResources::Base

  private

    def publication_params
      params.require(:publication).permit()
    end

end
