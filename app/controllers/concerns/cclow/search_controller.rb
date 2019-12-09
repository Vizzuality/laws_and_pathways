module CCLOW
  module SearchController
    extend ActiveSupport::Concern

    included do
      before_action :set_search_attributes, :set_recent_additions_attributes
    end

    def set_search_attributes
      # geography_columns = ::Geography.attribute_names -
      #   %w[created_at updated_at created_by_id updated_by_id discarded_at]
      # @search_geographies = ::Geography.select(geography_columns)
      # # without EXPLICITLY stating :id, there are duplicates in the result
      # laws_columns = Legislation.attribute_names -
      #   %w[id law_id geography_id slug updated_at
      #      created_by_id updated_by_id discarded_at sector_id parent_id]
      # @search_laws_and_policies = Legislation.joins(:geography)
      #   .where(legislations: {visibility_status: 'published'})
      #   .select(:id, laws_columns, 'geographies.name as geography_name')
      # litigation_columns = Litigation.attribute_names -
      #   %w[id slug citation_reference_number jurisdiction_id at_issue
      #      updated_at created_by_id updated_by_id discarded_at sector_id]
      # @search_litigations = Litigation.joins('LEFT JOIN geographies ON litigations.geography_id = geographies.id')
      #   .select(:id, litigation_columns, 'geographies.name as jurisdiction_name')
      #   .where(litigations: {visibility_status: 'published'})
      # target_columns = Target.attribute_names -
      #   %w[id geography_id target_scope_id created_at updated_at created_by_id updated_by_id discarded_at sector_id]
      # @search_targets = Target.published
      #   .joins(:geography).select(:id, target_columns, 'geographies.name as geography_name')
      @query = params[:q]
    end

    def set_recent_additions_attributes
      @search_recent_date = 1.month.ago.strftime('%F')
      # @recent_laws = Legislation.passed.where('events.date >= ?', @search_recent_date)
      # @recent_litigations = Litigation.started.where('events.date >= ?', @search_recent_date)

      # TODO: Revisit this again - now the latest additions are hardcoded to be always 5.
      # Look at the commented code above, we should filter by scopes
      @recent_laws = ::Api::LatestAdditions.new(5).serialize_legislations
      @recent_litigations = ::Api::LatestAdditions.new(5).serialize_litigations
      @recent_target
    end
  end
end
