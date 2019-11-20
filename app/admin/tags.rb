%w[
  Framework
  Keyword
  NaturalHazard
  PoliticalGroup
  Response
].each do |tag_class|
  ActiveAdmin.register tag_class.constantize do
    config.sort_order = 'name_asc'

    menu parent: 'Tags'

    permit_params :name

    filter :name_contains, label: 'Name'

    index do
      id_column
      column :name do |tag|
        link_to tag.name, resource_path(tag)
      end
      column :created_at
      column :updated_at
      column 'Actions' do |tag|
        div class: 'table_actions' do
          span link_to 'Edit', resource_path(tag)
          span link_to 'Delete', resource_path(tag),
                       method: :delete,
                       data: {confirm: 'Are you sure?'}
        end
      end
    end

    controller do
      def show
        redirect_to send("edit_admin_#{resource.class.name.underscore}_path")
      end

      def create
        create! { collection_path }
      end

      def update
        update! { collection_path }
      end
    end
  end
end
