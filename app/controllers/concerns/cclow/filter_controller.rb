module CCLOW
  module FilterController
    extend ActiveSupport::Concern

    def region_geography_options
      geography_options = {field_name: 'geography', options: ::Geography.all.map { |l| {value: l.id, label: l.name} }}
      region_options = {field_name: 'region', options: ::Geography::REGIONS.map { |l| {value: l, label: l} }}
      [region_options, geography_options]
    end

    def tags_options(taggable_type, type)
      name = type.downcase.pluralize
      tags = Tag.all.includes(:taggings).where(taggings: {taggable_type: taggable_type}, type: type)
      [{field_name: name, options: tags.map { |l| {value: l.id, label: l.name} }.sort_by { |h| h[:label] }}]
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

    def instruments_options
      instruments = Instrument.joins(:legislations).distinct.map { |j| {value: j.id, label: j.name} }
      [{field_name: 'instrument', options: instruments.sort_by { |h| h[:label] }}]
    end

    def governances_options
      governances = Governance.joins(:legislations).distinct.map { |j| {value: j.id, label: j.name} }
      [{field_name: 'governance', options: governances.sort_by { |h| h[:label] }}]
    end

    def litigation_side_a_party_type_options
      side_a_party_types = LitigationSide.where(side_type: 'a').pluck(:party_type).uniq.compact.map do |n|
        {value: n, label: n.humanize}
      end
      [{field_name: 'a_party_type', options: side_a_party_types.sort_by { |h| h[:label] }}]
    end

    def litigation_side_b_party_type_options
      side_b_party_types = LitigationSide.where(side_type: 'b').pluck(:party_type).uniq.compact.map do |n|
        {value: n, label: n.humanize}
      end
      [{field_name: 'b_party_type', options: side_b_party_types.sort_by { |h| h[:label] }}]
    end

    def litigation_side_c_party_type_options
      side_c_party_types = LitigationSide.where(side_type: 'c').pluck(:party_type).uniq.compact.map do |n|
        {value: n, label: n.humanize}
      end
      [{field_name: 'c_party_type', options: side_c_party_types.sort_by { |h| h[:label] }}]
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

    def sectors_options(class_name)
      name = class_name.downcase.pluralize
      sectors = LawsSector.joins(name.to_sym).distinct.map { |j| {value: j.id, label: j.name} }
      [{field_name: 'law_sector', options: sectors.sort_by { |h| h[:label] }}]
    end

    def target_years_options
      years = Target.select(:year).order(:year).distinct.pluck(:year).compact
      [{field_name: 'target_year', options: years.map { |y| {value: y, label: y} }}]
    end

    def filter_params
      params.permit(:q, :last_change_from, :last_change_to, :recent, :ids,
                    :law_passed_from, :law_passed_to, :case_started_from, :case_started_to,
                    target_year: [], region: [], geography: [], jurisdiction: [],
                    status: [], type: [], keywords: [], responses: [],
                    frameworks: [], natural_hazards: [], party_type: [],
                    side_a: [], side_b: [], side_c: [], law_sector: [],
                    a_party_type: [], b_party_type: [], c_party_type: [],
                    instrument: [], governance: [])
    end
  end
end
