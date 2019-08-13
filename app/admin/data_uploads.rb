ActiveAdmin.register DataUpload do
  menu parent: 'Administration', priority: 2

  config.batch_actions = false

  actions :index, :show, :new, :create

  permit_params :uploader, :file

  filter :created_at, label: 'Uploaded at'
  filter :uploaded_by
  filter :uploader, as: :select, collection: DataUpload::UPLOADERS

  index do
    id_column
    column :uploader
    column :uploaded_by
    column :uploaded_at, &:created_at
    column 'Actions' do |upload|
      div class: 'table_actions' do
        span link_to 'Show', resource_path(upload)
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :uploader
      row :uploaded_by
      row :file do
        link_to 'Uploaded file', rails_blob_path(resource.file, disposition: 'attachment')
      end
      row 'uploaded at', &:created_at
    end
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :uploader, as: :select, collection: DataUpload::UPLOADERS
      f.input :file, as: :file
    end

    f.actions do
      f.action :submit, label: 'Upload', button_html: {'data-disable-with' => 'Uploading...'}
      f.action :cancel
    end
  end

  # controller do
  #   def create
  #     uploader = params[:data_upload][:uploader]
  #     file = params[:data_upload][:file]


  #   end
  # end
end
