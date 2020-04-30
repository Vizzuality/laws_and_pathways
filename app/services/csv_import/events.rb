module CSVImport
  class Events < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        event = prepare_event(row)
        event.assign_attributes(event_attributes(row))

        was_new_record = event.new_record?
        any_changes = event.changed?

        event.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Event
    end

    def prepare_event(row)
      find_record_by(:id, row) ||
        Event.find_or_initialize_by(
          eventable_id: row[:eventable],
          eventable_type: row[:eventable_type],
          title: row[:title]
        )
    end

    def event_attributes(row)
      eventable_id = if row[:eventable_type] == 'Geography'
                       geographies[row[:eventable]]&.id
                     else
                       row[:eventable].to_i
                     end
      {
        eventable_id: eventable_id,
        eventable_type: row[:eventable_type].constantize,
        event_type: row[:event_type]&.downcase&.gsub(' ', '_'),
        title: (row[:title].presence || row[:event_type]),
        description: row[:description],
        date: event_date(row),
        url: row[:url]
      }
    end

    def event_date(row)
      CSVImport::DateUtils.safe_parse(row[:date], ['%d/%m/%Y', '%Y-%m-%d', '%Y']) if row[:date]
    end
  end
end
