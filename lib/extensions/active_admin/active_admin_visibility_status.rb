module ActiveAdminVisibilityStatus
  def publishable_scopes
    with_options group: :publishable_status do
      scope 'All', :not_archived, default: true
      scope 'Drafts', :draft
      scope 'Pending', :pending
      scope 'Published', :published
      scope 'Archived', :archived
    end
  end

  def publishable_resource_sidebar
    sidebar 'Publishing Status', only: :show, if: -> { can? :publish, resource.model } do
      attributes_table do
        tag_row :visibility_status, interactive: true
      end
    end
  end
end
