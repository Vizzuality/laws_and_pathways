module CSVImport
  class Events < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        event = prepare_event(row)

        event.eventable_id = parse_eventable_id(row) if row.header?(:eventable_id)
        event.eventable_type = row[:eventable_type].constantize if row.header?(:eventable_type)
        event.event_type = row[:event_type]&.downcase&.gsub(' ', '_') if row.header?(:event_type)
        event.title = (row[:title].presence || row[:event_type]) if row.header?(:title)
        event.description = row[:description] if row.header?(:description)
        event.date = event_date(row) if row.header?(:date)
        event.url = row[:url] if row.header?(:url)

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
          eventable_id: row[:eventable_id],
          eventable_type: row[:eventable_type],
          event_type: row[:event_type]&.downcase&.gsub(' ', '_'),
          title: row[:title]
        )
    end

    def parse_eventable_id(row)
      return geographies[row[:eventable_id]]&.id if row[:eventable_type] == 'Geography'

      row[:eventable_id].to_i
    end

    def event_date(row)
      CSVImport::DateUtils.safe_parse!(row[:date], ['%d/%m/%Y', '%Y-%m-%d', '%Y']) if row[:date]
    end
  end
end
