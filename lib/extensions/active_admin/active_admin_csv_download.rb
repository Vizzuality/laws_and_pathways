module ActiveAdminCsvDownload
  #
  # Generates Export Data sidebar section
  # - based on <sidebar_if_proc>
  # - generates CSV download links
  #
  def data_export_sidebar(resource_name)
    sidebar 'Export data', if: -> { collection.any? }, only: :index do
      ul do
        li do
          a "Download #{resource_name} CSV",
            href: url_for(
              params: request.query_parameters.except(:commit, :format),
              format: 'csv'
            )
        end
      end
      hr
    end
  end
end
