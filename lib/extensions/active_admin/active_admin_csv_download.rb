# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
module ActiveAdminCsvDownload
  #
  # Generates Export Data sidebar section.
  #
  # Sidebar contains CSV download links to:
  # - current resource list
  # - related Document list (optional, if :documents option is passed)
  # - related Event list (optional, if :events options is passed)
  #
  def data_export_sidebar(resource_name, options = {})
    export_link_for_documents = options.fetch(:documents) { false }
    export_link_for_events = options.fetch(:events) { false }

    sidebar 'Export / Import', if: -> { collection.any? }, only: :index do
      ul do
        li do
          a "Download #{resource_name} CSV",
            href: url_for(
              params: request.query_parameters.except(:commit, :format),
              format: 'csv'
            )
        end

        if export_link_for_documents
          li do
            a 'Download related Documents CSV', href: admin_documents_path(
              format: 'csv',
              q: {
                documentable_type_eq: resource_name.singularize,
                documentable: request.query_parameters[:q]
              }
            )
          end
        end

        if export_link_for_events
          li do
            a 'Download related Events CSV', href: admin_events_path(
              format: 'csv',
              q: {
                eventable_type_eq: resource_name.singularize,
                eventable: request.query_parameters[:q]
              }
            )
          end
        end

        li do
          link_to "<strong>Upload</strong> #{resource_name}".html_safe,
                  new_admin_data_upload_path(
                    data_upload: {uploader: resource_name}
                  )
        end
      end
      hr
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
