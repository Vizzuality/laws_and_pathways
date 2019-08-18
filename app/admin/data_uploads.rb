ActiveAdmin.register DataUpload do
  menu parent: 'Administration', priority: 2

  decorate_with DataUploadDecorator

  config.batch_actions = false

  actions :index, :show, :new, :create

  permit_params :uploader, :file

  filter :created_at, label: 'Uploaded at'
  filter :uploaded_by
  filter :uploader, as: :select, collection: DataUpload::UPLOADERS

  index do
    id_column
    column :uploader
    column :file
    column :uploaded_by
    column :uploaded_at
    column 'Actions' do |upload|
      div class: 'table_actions' do
        span link_to 'Show', resource_path(upload)
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :details
      row :uploader
      row :file
      row :uploaded_by
      row :uploaded_at
    end
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    div class: 'padding-20' do
      'Only CSV files are allowed. Please make sure that imported file is UTF-8 encoded.
       Otherwise you may see UTF-8 errors while importing the file'
    end

    f.inputs do
      f.input :uploader, as: :select, hint: 'Choose data model', collection: DataUpload::UPLOADERS
      f.input :file, as: :file, hint: preview_file_tag(f.object.file)
    end

    f.actions do
      f.action :submit, label: 'Upload', button_html: {'data-disable-with' => 'Uploading...'}
      f.action :cancel, wrapper_html: {class: 'cancel'}
    end
  end

  controller do
    def create
      @data_upload = build_new_resource

      if @data_upload.save
        redirect_to admin_data_upload_path(@data_upload.data_upload)
      else
        render :new
      end
    end

    def build_new_resource
      DataUploadForm.new(permitted_params[:data_upload])
    end
  end
end
