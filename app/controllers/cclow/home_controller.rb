module CCLOW
  class HomeController < CCLOWController
    def index 
      @geographies = Geography.all
      # without EXPLICITLY stating :id, there are duplicates in the result
      laws_columns = Legislation.attribute_names - ['id']
      @laws_and_policies = Legislation.joins(:geography).select(:id, laws_columns, 'geographies.name as geography_name')
      litigation_columns = Litigation.attribute_names - ['id']
      @litigations = Litigation.joins(:jurisdiction).select(:id, litigation_columns, 'geographies.name as jurisdiction_name')
      target_columns = Target.attribute_names - ['id']
      @targets = Target.joins(:geography).select(:id, target_columns, 'geographies.name as geography_name')
      @recent_date = 1.year.ago.strftime("%F")
    end
  end
end
