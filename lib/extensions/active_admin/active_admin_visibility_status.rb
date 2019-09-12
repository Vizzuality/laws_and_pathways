module ActiveAdminVisibilityStatus
  def publishable_scopes
    with_options group: :publishable_status do
      scope 'All', :not_archived, default: true
      scope 'Draft', :draft
      scope 'Pending', :pending
      scope 'Published', :published
      scope 'Archived', :archived
    end
  end

  def publishable_sidebar(*args)
    sidebar 'Publishing Status', *args do
      attributes_table do
        tag_row :visibility_status, interactive: true
      end
    end
  end
end
