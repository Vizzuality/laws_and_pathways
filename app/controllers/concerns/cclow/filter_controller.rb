module CCLOW
  module FilterController
    extend ActiveSupport::Concern

    def region_geography_options
      geography_options = {field_name: 'geography', options: ::Geography.all.map { |l| {value: l.id, label: l.name} }}
      region_options = {field_name: 'region', options: ::Geography::REGIONS.map { |l| {value: l, label: l} }}
      [region_options, geography_options]
    end

    def tags_options(taggable_type)
      tags = Tag.all.includes(:taggings).where(taggings: {taggable_type: taggable_type})
      [{field_name: 'tags', options: tags.map { |l| {value: l.id, label: l.name} }}]
    end

    def litigation_statuses_options
      statuses = Litigation::EVENT_TYPES.map { |l| {value: l, label: l.humanize} }
      [{field_name: 'status', options: statuses}]
    end

    def legislation_types_options
      types = Legislation::LEGISLATION_TYPES.map { |l| {value: l, label: l.humanize} }
      [{field_name: 'type', options: types}]
    end

    def target_types_options
      types = Target::TYPES.map { |l| {value: l, label: l.humanize} }
      [{field_name: 'type', options: types}]
    end

    def litigation_side_types_options
      side_types = LitigationSide::SIDE_TYPES.map { |t| {value: t, label: t.humanize} }
      [{field_name: 'side_type', options: side_types}]
    end

    def litigation_party_types_options
      party_types = LitigationSide::PARTY_TYPES.map { |t| {value: t, label: t.humanize} }
      [{field_name: 'party_type', options: party_types}]
    end

    def filter_params
      params.permit(:q, :from_date,
                    :to_date, :recent, :ids, region: [], geography: [],
                                             status: [], type: [], tags: [], party_type: [], side_type: [])
    end
  end
end
