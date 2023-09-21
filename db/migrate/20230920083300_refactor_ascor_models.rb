class RefactorASCORModels < ActiveRecord::Migration[6.1]
  def change
    ### ASCOR Countries ###
    add_column :ascor_countries, :type_of_party, :string, null: true
    ### ASCOR Benchmarks ###
    remove_column :ascor_benchmarks, :land_use
    ### ASCOR Pathways ###
    remove_column :ascor_pathways, :land_use
    add_column :ascor_pathways, :trend_source, :string, null: true
    add_column :ascor_pathways, :trend_year, :integer, null: true
    add_column :ascor_pathways, :recent_emission_level, :float, null: true
    add_column :ascor_pathways, :recent_emission_source, :string, null: true
    add_column :ascor_pathways, :recent_emission_year, :integer, null: true
    rename_column :ascor_pathways, :last_reported_year, :last_historical_year
    ### ASCOR Assessment Indicators ###
    add_column :ascor_assessment_indicators, :units_or_response_type, :string, null: true
    ### ASCOR Assessments ###
    remove_column :ascor_assessments, :research_notes
    remove_column :ascor_assessments, :further_information
    add_column :ascor_assessments, :notes, :text, null: true
    remove_column :ascor_assessment_results, :source_name
    remove_column :ascor_assessment_results, :source_date
    remove_column :ascor_assessment_results, :source_link
    add_column :ascor_assessment_results, :source, :string, null: true
    add_column :ascor_assessment_results, :year, :integer, null: true
  end
end
