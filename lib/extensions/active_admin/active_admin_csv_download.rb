module ActiveAdminCsvDownload
  #
  # Generates Export Data sidebar section.
  #
  # Sidebar contains CSV download links to:
  # - current resource list
  # - related Document list (optional, if :documents option is passed)
  # - related Event list (optional, if :events options is passed)
  # Link to uploader could be removed passing :upload option false
  def data_export_sidebar(resource_name, options = {}, &block)
    export_link_for_documents = options.fetch(:documents, false)
    export_link_for_events = options.fetch(:events, false)
    display_name = options.fetch(:display_name) { resource_name }
    show_display_name = options.fetch(:show_display_name, true)
    show_upload = options.fetch(:upload, true)

    sidebar 'Export / Import', only: :index do
      ul do
        if show_display_name
          li do
            link_to "Download #{display_name} CSV",
                    params: request.query_parameters.except(:commit, :format),
                    format: 'csv'
          end
        end

        if export_link_for_documents
          li do
            link_to 'Download related Documents CSV', admin_documents_path(
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
            link_to 'Download related Events CSV', admin_events_path(
              format: 'csv',
              q: {
                eventable_type_eq: resource_name.singularize,
                eventable: request.query_parameters[:q]
              }
            )
          end
        end

        instance_eval(&block) if block

        if show_upload
          li do
            upload_label = "<strong>Upload</strong> #{display_name}".html_safe
            upload_path = new_admin_data_upload_path(data_upload: {uploader: resource_name})

            link_to upload_label, upload_path
          end
        end
      end
      hr
    end
  end
end
# rubocop:enable
