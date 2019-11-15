ActiveAdmin.register_page 'Activity Log' do
  menu parent: 'Administration', priority: 3

  content do
    panel 'Activity Log (paper_trail), [Companies, Geo]' do
      section do
        table_for PaperTrail::Version.order('id desc').limit(20) do
          column ("Item") { |v| v.item || '[Record deleted (TODO: find it by all_discarded scope)]' }
          column ("Type") { |v| v.item_type.underscore.humanize }
          column ("Updated at") { |v| v.created_at.to_s :long }
          column ("Whodunnit") { |v| v.whodunnit }
          column ('Details') { |v| v.changeset }
        end
      end
    end

    panel 'Activity Log (logidze), [Legislations, Targets]' do
      section do
        audited_records = {
          legislations: Legislation.where.not(log_data: nil).order(updated_at: :desc),
          targets: Target.where.not(log_data: nil).order(updated_at: :desc)
        }

        changesets = audited_records.flat_map do |collection_name, collection|
          collection.flat_map do |record|
            record_updates = record.log_data.versions.each_cons(2).map do |before, after|
              record.at(time: after.time).diff_from(time: before.time)
            end

            record_updates.reverse.compact.map do |record_update|
              {
                item: record,
                type: record.class.name,
                updated_at: record_update['changes']['updated_at']['new'],
                changes: record_update['changes'].except('updated_at'),
                made_by: record.log_data.responsible_id
              }
            end
          end
        end

        # presentation
        table_for changesets do
          column ("Item") { |v| v[:item] }
          column ("Type") { |v| v[:type] }
          column ("Updated at") { |v| v[:updated_at] }
          column ("Whodunnit") { |v| v[:made_by] }
          column ("Details") { |v| v[:changes].map { |name, changes| "#{name} (#{changes['old']} => #{changes['new']})" }.join(', ') }
        end
      end
    end
  end
end
