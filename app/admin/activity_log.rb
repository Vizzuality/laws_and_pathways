ActiveAdmin.register_page 'Activity Log' do
  menu parent: 'Administration', priority: 3

  content do
    panel 'Activity Log' do
      section 'Using paper_trail (Companies, Geographies)' do
        table_for PaperTrail::Version.order('id desc').limit(20) do # Use PaperTrail::Version if this throws an error
        column ("Item") { |v| v.item || '[Record deleted (TODO: find it by all_discarded scope)]' }
        # column ("Item") { |v| link_to v.item, [:admin, v.item] } # Uncomment to display as link
        column ("Type") { |v| v.item_type.underscore.humanize }
        column ("Modified at") { |v| v.created_at.to_s :long }
        column ("Admin") { |v| link_to AdminUser.find_by_email(v.whodunnit).email, [:admin, AdminUser.find_by_email(v.whodunnit)] }
        end
      end
    end
  end
end
