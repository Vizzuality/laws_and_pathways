module Api
  class LatestAdditions
    def initialize(count)
      @count = count
    end

    def call
      (serialize_litigations + serialize_legislations).sort_by { |item| - item[:created_at].to_time.to_i }
    end

    private

    def serialize_litigations
      Litigation.last(@count).map do |item|
        addition_type = if item.events.last&.event_type.present?
                          I18n.t("cclow.litigation.event_types.#{item.events.last&.event_type}")
                        end
        {kind: 'Litigation cases',
         title: item.title,
         date_passed: item.started_event&.date&.year,
         iso: item.jurisdiction.iso,
         addition_type: addition_type,
         jurisdiction: item.jurisdiction.name,
         created_at: item.created_at}
      end
    end

    def serialize_legislations
      Legislation.last(@count).map do |item|
        {kind: 'Laws and policies',
         title: item.title,
         date_passed: item.date_passed&.year,
         iso: item.geography.iso,
         addition_type: I18n.t("cclow.legislation_types.#{item.legislation_type}"),
         jurisdiction: item.geography.name,
         created_at: item.created_at}
      end
    end
  end
end
