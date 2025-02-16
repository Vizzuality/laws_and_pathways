ActiveAdmin.register Company do
  menu priority: 2, parent: 'TPI'

  decorate_with CompanyDecorator

  config.sort_order = 'name_asc'
  config.batch_actions = false

  publishable_scopes
  publishable_resource_sidebar

  permit_params :name, :isin, :sector_id, :geography_id, :headquarters_geography_id,
                :ca100, :market_cap_group, :visibility_status, :sedol,
                :latest_information, :company_comments_internal, :active

  filter :isin_contains, label: 'ISIN'
  filter :name_contains, label: 'Name'
  filter :geography
  filter :sector
  filter :headquarters_geography
  filter :active
  filter :created_at
  filter :market_cap_group,
         as: :check_boxes,
         collection: proc { array_to_select_collection(Company::MARKET_CAP_GROUPS) }

  data_export_sidebar 'Companies'

  sidebar 'Details', only: :show do
    attributes_table do
      row :company, &:name
      row :active, &:active
      row :level, &:mq_level_tag
      row :updated_at
    end
  end

  action_item :preview, priority: 0, only: :show do
    link_to 'Preview', resource.preview_url if resource.published?
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :name
          row :slug
          row :active
          row :sector
          row :isin, &:isin_as_tags
          row :sedol
          row :geography
          row :headquarters_geography
          row :ca100
          row :market_cap_group
          row 'Management Quality Level', &:mq_level_tag
          row :latest_information
          row :company_comments_internal
          row :created_at
          row :updated_at
        end
      end

      tab :mq_assessments do
        panel 'Management Quality Assessments' do
          if resource.mq_assessments.empty?
            div class: 'padding-20' do
              'No Management Quality Assessments for this company yet'
            end
          else
            resource.mq_assessments.latest_first.decorate.map do |a|
              panel a.title_link, class: 'mq_assessment' do
                attributes_table_for a do
                  row :level, &:level_tag
                  row :publication_date
                  row :assessment_date
                end

                table_for a.questions do
                  column :level
                  column :answer
                  column :question
                end
              end
            end
          end
        end
      end

      tab :cp_assessments do
        panel 'Carbon Performance Assessments' do
          if resource.cp_assessments.empty?
            div class: 'padding-20' do
              'No Carbon Performance Assessments for this company yet'
            end
          else
            resource.cp_assessments.latest_first.decorate.map do |a|
              panel a.title_link, class: 'benchmark' do
                attributes_table_for a do
                  row :publication_date
                  row :assessment_date
                  row :cp_alignment_2025
                  row :cp_alignment_2027
                  row :cp_alignment_2028
                  row :cp_alignment_2035
                  row :cp_alignment_2050
                  if a.region.present?
                    row :region
                    row :cp_regional_alignment_2025
                    row :cp_regional_alignment_2027
                    row :cp_regional_alignment_2028
                    row :cp_regional_alignment_2035
                    row :cp_regional_alignment_2050
                  end
                  row :assumptions
                  row :last_reported_year
                end

                render 'admin/cp/emissions_table', emissions: a.emissions
              end
            end
          end
        end
      end

      tab :litigations do
        panel 'Connected Litigations' do
          if resource.litigations.empty?
            div class: 'padding-20' do
              'No Litigations are connected with this company'
            end
          else
            table_for resource.litigations.decorate do
              column :title, &:title_link
            end
          end
        end
      end
    end

    active_admin_comments
  end

  index do
    column(:name) { |company| link_to company.name, admin_company_path(company) }
    column :sector
    column :level, &:mq_level_tag
    column :geography
    column :active
    tag_column :visibility_status

    actions
  end

  csv do
    column :id
    column :name
    column :isin
    column(:sector) { |c| c.sector.name }
    column :market_cap_group
    column :sedol
    column(:geography_iso) { |c| c.geography.iso }
    column(:geography) { |c| c.geography.name }
    column(:headquarters_geography_iso) { |c| c.headquarters_geography.iso }
    column(:headquarters_geography) { |c| c.headquarters_geography.name }
    column :latest_information
    column :company_comments_internal
    column :ca100
    column :active
    column :visibility_status
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs do
      columns do
        column { f.input :name }
        column { f.input :isin, as: :tags }
        column { f.input :sedol }
      end

      columns do
        column { f.input :sector, collection: TPISector.companies.tpi_tool }
        column do
          f.input :market_cap_group,
                  as: :select,
                  collection: array_to_select_collection(Company::MARKET_CAP_GROUPS)
        end
      end

      columns do
        column { f.input :geography }
        column { f.input :headquarters_geography }
        column do
          f.input :visibility_status, as: :select
        end
      end

      f.input :active

      f.input :ca100

      f.input :latest_information,
              hint: 'Information displayed on the company page of TPI'
      f.input :company_comments_internal,
              hint: 'Name changes, or other historical information, not displayed on the public interface'
    end

    f.actions
  end

  controller do
    def scoped_collection
      super.includes(
        :geography,
        :sector,
        :headquarters_geography,
        :latest_mq_assessment_only_beta_methodologies,
        :latest_mq_assessment_without_beta_methodologies,
        *csv_includes
      )
    end

    def csv_includes
      return [] unless csv_format?

      [:sector]
    end

    def csv_format?
      request[:format] == 'csv'
    end

    def destroy
      destroy_command = ::Command::Destroy::Company.new(resource.object)

      message = if destroy_command.call
                  {notice: 'Successfully deleted selected Company'}
                else
                  {alert: 'Could not delete selected Company'}
                end

      redirect_to admin_companies_path, message
    end
  end
end
