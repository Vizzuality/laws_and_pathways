module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy
  end

  class_methods do
    def with_last_events
      last_events_sql = <<-SQL
        LEFT OUTER JOIN (
          SELECT DISTINCT ON(le.eventable_id) *
          FROM Events le
          WHERE le.eventable_type = '#{model_name}'
          ORDER BY le.eventable_id, le.date DESC NULLS LAST
        ) AS last_events ON last_events.eventable_id = #{table_name}.id
      SQL

      joins(last_events_sql)
    end
  end
end
