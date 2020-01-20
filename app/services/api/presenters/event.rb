module Api
  module Presenters
    class Event
      attr_reader :event, :timeline_type, :eventable

      def self.call(event, timeline_type)
        new(event, timeline_type).call
      end

      def initialize(event, timeline_type)
        @event = event
        @eventable = event.eventable
        @timeline_type = timeline_type
      end

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
          link: link
        }
      end

      private

      def link
        if eventable.is_a?(Legislation)
          legislation_route
        elsif eventable.is_a?(Litigation)
          url.cclow_geography_litigation_case_path(
            eventable&.geography_id, eventable
          )
        elsif eventable.is_a?(Geography)
          url.cclow_geography_path(eventable)
        end
      end

      def legislation_route
        if eventable.law?
          url.cclow_geography_law_path(eventable&.geography_id, eventable)
        else
          url.cclow_geography_policy_path(eventable&.geography_id, eventable)
        end
      end

      def url
        Rails.application.routes.url_helpers
      end
    end
  end
end
