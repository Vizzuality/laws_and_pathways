ActiveAdmin.register_page 'Activity Log' do
  menu parent: 'Administration', priority: 3

  content do
    panel 'Activity Log (paper_trail), [Companies, Geo]' do
      section do
        # all tracked models versions are automatically fetched
        record_versions_paper_trail = PaperTrail::Version.order('id desc').limit(20)

        changesets_paper_trail = record_versions_paper_trail.map do |record_version|
          {
            item: record_version.item || 'DELETED',
            type: record_version.item_type.underscore.humanize,
            updated_at: record_version.created_at.to_s,
            made_by: record_version.whodunnit,
            changes: record_version.changeset.except('updated_at', 'updated_by_id')
          }
        end

        table_for(changesets_paper_trail) do
          column('Item') { |v| v[:item] }
          column('Type') { |v| v[:type] }
          column('Updated at') { |v| v[:updated_at] }
          column('Whodunnit') { |v| v[:made_by] }
          column('Details') { |v| v[:changes] }
        end
      end
    end

    panel 'Activity Log (logidze), [Legislations, Targets]' do
      section do
        # need to define which models we want
        klasses = [Legislation, Target]

        changesets_logidze = klasses.flat_map do |klass|
          klass.where.not(log_data: nil).order(updated_at: :desc).flat_map do |record|
            record_updates = record.log_data.versions.each_cons(2).map do |before, after|
              record.at(time: after.time).diff_from(time: before.time)
            end

            record_updates.reverse.compact.map do |record_update|
              single_record_changes = record_update['changes']
                .except('updated_at')
                .map { |name, changes| {name => [changes['old'], changes['new']]} }

              {
                item: record,
                type: record.class.name,
                updated_at: record_update['changes']['updated_at']['new'],
                changes: single_record_changes,
                made_by: record.log_data.responsible_id
              }
            end
          end
        end

        table_for(changesets_logidze) do
          column('Item') { |v| v[:item] }
          column('Type') { |v| v[:type] }
          column('Updated at') { |v| v[:updated_at] }
          column('Whodunnit') { |v| v[:made_by] }
          column('Details') { |v| v[:changes] }
        end
      end
    end
  end
end
