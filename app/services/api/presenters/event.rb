module Api
  module Presenters
    class Event
      attr_reader :event, :timeline_type

      def self.call(event, timeline_type)
        new(event, timeline_type).call
      end

      def initialize(event, timeline_type)
        @event = event
        @timeline_type = timeline_type
      end

      # rubocop:disable Metrics/AbcSize
      def call
        {
          id: event.id,
          eventable_id: event.eventable_id,
          eventable_type: event.eventable_type,
          title: event.title,
          event_type: event.event_type,
          date: event.date,
          description: event.description,
          eventable_title: timeline_type.eql?(:geography) ? event.eventable_title : event.description || event.title,
          link: link(event.eventable_type, event.eventable_id)
        }
      end
      # rubocop:enable Metrics/AbcSize

      private

      def link(eventable_type, eventable_id)
        if eventable_type.eql?('Legislation')
          legislation_route(Legislation.find(eventable_id)&.geography_id, Legislation.find(eventable_id))
        elsif eventable_type.eql?('Litigation')
          url.cclow_geography_litigation_case_path(
            Litigation.find(eventable_id)&.geography_id,
            Litigation.find(eventable_id)
          )
        elsif eventable_type.eql?('Geography')
          url.cclow_geography_path(eventable_id)
        end
      end

      def legislation_route(geography, legislation)
        if legislation.law?
          url.cclow_geography_law_path(geography, legislation)
        else
          url.cclow_geography_policy_path(geography, legislation)
        end
      end

      def url
        Rails.application.routes.url_helpers
      end
    end
  end
end
