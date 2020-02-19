module CCLOW
  class LitigationCasesController < CCLOWController
    include FilterController

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def index
      add_breadcrumb('Climate Change Laws of the World', cclow_root_path)
      add_breadcrumb('Litigation cases', cclow_litigation_cases_path(@geography))
      add_breadcrumb('Search results', request.path) if params[:q].present? || params[:recent].present?

      @litigations = Queries::CCLOW::LitigationQuery.new(filter_params).call

      fixed_navbar('All Litigation Cases', admin_litigations_path)

      respond_to do |format|
        format.html do
          render component: 'pages/cclow/LitigationCases', props: {
            geo_filter_options: region_geography_options,
            keywords_filter_options: tags_options('Litigation', 'Keyword'),
            responses_filter_options: tags_options('Litigation', 'Response'),
            statuses_filter_options: litigation_statuses_options,
            litigation_side_a_names_options: litigation_side_a_names_options,
            litigation_side_b_names_options: litigation_side_b_names_options,
            litigation_side_c_names_options: litigation_side_c_names_options,
            litigation_party_types_options: litigation_party_types_options,
            litigation_jurisdictions_options: litigation_jurisdictions_options,
            litigation_side_a_party_type_options: litigation_side_a_party_type_options,
            litigation_side_b_party_type_options: litigation_side_b_party_type_options,
            litigation_side_c_party_type_options: litigation_side_c_party_type_options,
            litigations: CCLOW::LitigationDecorator.decorate_collection(@litigations.first(10)),
            count: @litigations.size
          }, prerender: false
        end
        format.json do
          render json: {
            litigations: CCLOW::LitigationDecorator.decorate_collection(
              @litigations.offset(params[:offset] || 0).take(10)
            ),
            count: @litigations.size
          }
        end
        format.csv do
          timestamp = Time.now.strftime('%d%m%Y')
          litigations = Litigation
            .where(id: @litigations.pluck(:id))
            .includes(
              :geography, :responses, :keywords,
              :events, :legislations, :external_legislations
            )

          render csv: CSVExport::User::Litigations.new(litigations).call,
                 filename: "litigation_cases_#{timestamp}"
        end
      end
    end

    private

    def sort_list(litigations)
      return litigations if (filter_params.keys - %w(from_date to_date)).present?

      sql = <<-SQL
        LEFT OUTER JOIN events ON events.eventable_id = litigations.id
        AND events.eventable_type = 'Litigation'
        AND events.event_type IN (#{Litigation::EVENT_STARTED_TYPES.map { |type| "'#{type}'" }.join(', ')})
      SQL

      Litigation.where(id: litigations.map(&:id)).joins(sql).order('events.date DESC NULLS LAST')
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
