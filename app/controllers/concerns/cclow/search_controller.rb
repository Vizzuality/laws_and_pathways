module CCLOW
  module SearchController
    extend ActiveSupport::Concern

    included do
      before_action :set_search_attributes
    end

    def set_search_attributes 
      @search_geographies = ::Geography.all
      # without EXPLICITLY stating :id, there are duplicates in the result
      laws_columns = Legislation.attribute_names - ['id']
      @search_laws_and_policies = Legislation.joins(:geography).select(:id, laws_columns, 'geographies.name as geography_name')
      litigation_columns = Litigation.attribute_names - ['id']
      @search_litigations = Litigation.joins(:jurisdiction).select(:id, litigation_columns, 'geographies.name as jurisdiction_name')
      target_columns = Target.attribute_names - ['id']
      @search_targets = Target.joins(:geography).select(:id, target_columns, 'geographies.name as geography_name')
      @search_recent_date = 1.year.ago.strftime("%F")
    end

  end
end