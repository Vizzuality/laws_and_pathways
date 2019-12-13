module Api
  class LatestAdditions
    include ActionView::Helpers::UrlHelper

    def initialize(count)
      @count = count
    end

    def call
      (litigations + legislations).sort_by { |item| - (item[:date_passed] || 0) }
    end

    private

    # rubocop:disable Metrics/AbcSize
    def litigations
      litigations = Litigation.published
        .joins(:events)
        .order('events.date ASC, litigations.created_at ASC')
        .last(@count)
      CCLOW::LitigationDecorator.decorate_collection(litigations).map do |item|
        addition_type = item.events.last&.event_type&.humanize if item.events.last&.event_type.present?

        {kind: 'Litigation cases',
         id: item.id,
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

    def legislations
      legislation = Legislation.published
        .joins(:events)
        .order('events.date ASC, legislations.created_at ASC')
        .last(@count)
      CCLOW::LegislationDecorator.decorate_collection(legislation).map do |item|
        {kind: 'Laws and policies',
         id: item.id,
         title: item.title,
         date_passed: item.date_passed&.year,
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
