ActiveAdmin.register LitigationSide do
  menu false

  actions :index

  csv do
    column :id
    column 'Litigation ID', &:litigation_id
    column :connected_entity_type
    column 'Connected entity ID', &:connected_entity_id
    column :name
    column :side_type
    column :party_type
  end

  controller do
    def index
      super do |format|
        format.html { redirect_to admin_dashboard_path }
      end
    end

    def scoped_collection
      results = super.includes(:connected_entity)

      return results unless litigation_params

      results.where(litigation: litigation_scope)
    end

    private

    def litigation_scope
      Litigation.ransack(litigation_params)&.result
    end

    def litigation_params
      @litigation_params ||= params.dig(:q, :litigation)
    end
  end
end
