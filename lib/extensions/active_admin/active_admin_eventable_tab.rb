module ActiveAdminEventableTab
  def eventable_tab(title)
    tab :events do
      panel(title) do
        table_for resource.events.order(date: :desc).decorate do
          column :date
          column :event_type
          column :title
          column :description
          column 'URL', &:url_link
        end
      end
    end
  end
end
