ActiveAdmin.register Company do
  menu priority: 0, parent: 'TPI'

  decorate_with CompanyDecorator

  config.sort_order = 'name_asc'
  config.batch_actions = false

  publishable_scopes
  publishable_sidebar only: :show

  permit_params :name, :isin, :sector_id, :geography_id, :headquarters_geography_id,
                :ca100, :size, :visibility_status

  filter :isin_contains, label: 'ISIN'
  filter :name_contains, label: 'Name'
  filter :geography
  filter :headquarters_geography
  filter :size,
         as: :check_boxes,
         collection: proc { array_to_select_collection(Company::SIZES) }

  data_export_sidebar 'Companies'

  sidebar 'Details', only: :show do
    attributes_table do
      row :company, &:name
      row :level, &:mq_status_description_short
      row :updated_at
    end
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :name
          row :slug
          row :sector
          row :isin, &:isin_as_tags
          row :geography
          row :headquarters_geography
          row :ca100
          row :size
          row 'Management Quality Level', &:mq_status_description_short
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
              panel a.title, class: 'mq_assessment' do
                attributes_table_for a do
                  row :level, &:status_description_short
                  row :publication_date
                  row :assessment_date
                end

                table_for a.questions do
                  column(:level) { |q| q['level'] }
                  column(:answer) { |q| q['answer'] }
                  column(:question) { |q| q['question'] }
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
              div class: 'panel benchmark' do
                attributes_table_for a do
                  row :publication_date
                  row :assessment_date
                  row :assumptions
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
  end

  index do
    column(:name) { |company| link_to company.name, admin_company_path(company) }
    column :isin, &:isin_as_tags
    column(:size) { |company| company.size.humanize }
    column :level, &:mq_status_description_short
    column :geography
    column :headquarters_geography
    tag_column :visibility_status

    actions
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      columns do
        column { f.input :name }
        column { f.input :isin, as: :tags }
      end

      columns do
        column { f.input :sector }
        column do
          f.input :size,
                  as: :select,
                  collection: array_to_select_collection(Company::SIZES)
        end
      end

      columns do
        column { f.input :geography }
        column { f.input :headquarters_geography }
        column do
          f.input :visibility_status, as: :select
        end
      end

      f.input :ca100
    end

    f.actions
  end

  controller do
    def scoped_collection
      super.includes(:geography, :headquarters_geography, :mq_assessments)
    end
  end
end
