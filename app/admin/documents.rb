ActiveAdmin.register Document do
  menu priority: 6

  decorate_with DocumentDecorator

  filter :name_contains
  filter :documentable_type, label: 'Attached to'
  filter :language,
         as: :select,
         collection: proc { all_languages_to_select_collection }

  config.batch_actions = false

  actions :all, except: [:new, :edit, :create, :update]

  show do
    attributes_table do
      row :id
      row :name
      row :link, &:document_url_link
      row :language
      row :last_verified_on
      row :created_at
      row :updated_at
    end
  end

  index do
    column 'Name', &:document_page_link
    column 'Attached To', :documentable
    column :last_verified_on
    column :language
    actions
  end

  controller do
    def scoped_collection
      super.includes(:documentable)
    end
  end
end
