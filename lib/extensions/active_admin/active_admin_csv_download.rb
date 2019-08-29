module ActiveAdminCsvDownload
  #
  # Generates Export Data sidebar section.
  #
  # Sidebar contains CSV download links to:
  # - current resource list
  # - related Documents list (optional, if :documents option is passed)
  #
  def data_export_sidebar(resource_name, options = {})
    documents_export_link = options.fetch(:documents) { false }

    sidebar 'Export data', if: -> { collection.any? }, only: :index do
      ul do
        li do
          a "Download #{resource_name} CSV",
            href: url_for(
              params: request.query_parameters.except(:commit, :format),
              format: 'csv'
            )
        end

        if documents_export_link
          li do
            a 'Download related Documents CSV',
              href: admin_documents_path(
                format: 'csv',
                q: {
                  documentable_type_eq: resource_name.singularize,
                  documentable: request.query_parameters[:q]
                }
              )
          end
        end
      end
      hr
    end
  end
end
