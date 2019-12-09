module Api
  class LatestAdditions
    include ActionView::Helpers::UrlHelper

    def initialize(count)
      @count = count
    end

    def call
      (serialize_litigations + serialize_legislations).sort_by { |item| - (item[:date_passed] || 0) }
    end

    private

    # rubocop:disable Metrics/AbcSize
    def serialize_litigations
      CCLOW::LitigationDecorator.decorate_collection(Litigation.published.last(@count)).map do |item|
        addition_type = item.events.last&.event_type&.humanize if item.events.last&.event_type.present?

        {kind: 'Litigation cases',
         title: item.title,
         date_passed: item.started_event&.date&.year,
         iso: item.geography.iso,
         addition_type: addition_type,
         jurisdiction: item.jurisdiction,
         jurisdiction_link: link_to(item.geography.name, url.cclow_geography_path(item.geography)),
         link: item.link}
      end
    end
    # rubocop:enable Metrics/AbcSize

    def serialize_legislations
      CCLOW::LegislationDecorator.decorate_collection(Legislation.published.last(@count)).map do |item|
        {kind: 'Laws and policies',
         title: item.title,
         date_passed: item.updated_at&.year,
         iso: item.geography.iso,
         addition_type: I18n.t("cclow.legislation_types.#{item.legislation_type}"),
         jurisdiction: item.geography,
         jurisdiction_link: link_to(item.geography.name, url.cclow_geography_path(item.geography.slug)),
         link: item.link}
      end
    end

    def url
      Rails.application.routes.url_helpers
    end
  end
end
