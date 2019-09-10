module ActiveAdminVisibilityStatus
  def visibility_status_scopes
    with_options group: :publishable_status do
      scope 'All', :all, default: true
      scope 'Draft', :draft
      scope 'Pending', :pending
      scope 'Published', :published
      scope 'Archived', :archived
    end
  end

  def visibility_status_sidebar(*args)
    sidebar 'Publishing Status', *args do
      attributes_table do
        tag_row :visibility_status, interactive: true
      end
    end
  end
end
