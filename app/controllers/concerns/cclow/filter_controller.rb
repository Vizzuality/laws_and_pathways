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
      [{field_name: 'tags', options: tags.map { |l| {value: l.id, label: l.name} }.sort_by { |h| h[:label] }}]
    end

    def litigation_statuses_options
      statuses = Litigation::EVENT_TYPES.map { |l| {value: l, label: l.humanize} }
      [{field_name: 'status', options: statuses.sort_by { |h| h[:label] }}]
    end

    def legislation_types_options
      types = Legislation::LEGISLATION_TYPES.map { |l| {value: l, label: l.humanize} }
      [{field_name: 'type', options: types.sort_by { |h| h[:label] }}]
    end

    def target_types_options
      types = Target::TYPES.map { |l| {value: l, label: l.humanize} }
      [{field_name: 'type', options: types.sort_by { |h| h[:label] }}]
    end

    def litigation_side_a_names_options
      side_a = LitigationSide.where(side_type: 'a').pluck(:name).uniq.map { |n| {value: n, label: n.humanize} }
      [{field_name: 'side_a', options: side_a.sort_by { |h| h[:label] }}]
    end

    def litigation_side_b_names_options
      side_b = LitigationSide.where(side_type: 'b').pluck(:name).uniq.map { |n| {value: n, label: n.humanize} }
      [{field_name: 'side_b', options: side_b.sort_by { |h| h[:label] }}]
    end

    def litigation_side_c_names_options
      side_c = LitigationSide.where(side_type: 'c').pluck(:name).uniq.map { |n| {value: n, label: n.humanize} }
      [{field_name: 'side_c', options: side_c.sort_by { |h| h[:label] }}]
    end

    def litigation_party_types_options
      party_types = LitigationSide::PARTY_TYPES.map { |t| {value: t, label: t.humanize} }
      [{field_name: 'party_type', options: party_types.sort_by { |h| h[:label] }}]
    end

    def litigation_jurisdictions_options
      jurisdiction_types = Litigation.pluck(:jurisdiction).uniq.map { |j| {value: j, label: j.humanize} }
      [{field_name: 'jurisdiction', options: jurisdiction_types.sort_by { |h| h[:label] }}]
    end

    def filter_params
      params.permit(:q, :from_date,
                    :to_date, :recent, :ids, region: [], geography: [], jurisdiction: [],
                                             status: [], type: [], tags: [], party_type: [],
                                             side_a: [], side_b: [], side_c: [])
    end
  end
end
