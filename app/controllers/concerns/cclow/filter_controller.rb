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

    def filter_params
      params.permit(:q, :from_date, :to_date, :recent, :ids, region: [], geography: [], tags: [])
    end
  end
end
