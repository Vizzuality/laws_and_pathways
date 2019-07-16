ActiveAdmin.register Company do
  menu priority: 4

  permit_params :name, :isin, :sector_id, :location_id, :headquarter_location_id, :ca100,
                :size

  filter :isin_contains, label: 'ISIN'
  filter :name_contains, label: 'Name'
  filter :location
  filter :headquarter_location
  filter :size, as: :check_boxes, collection: proc { array_to_select_collection(Company::SIZES) }

  config.batch_actions = false

  sidebar 'Details', only: :show do
    attributes_table do
      row :company, &:name
      row :level do
        if resource.mq_level.present?
          div do
            "#{resource.mq_level} (#{resource.mq_status})"
          end
        end
      end
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
          row :isin
          row :location
          row :headquarter_location
          row :ca100
          row :size
          row 'Management Quality Level' do
            if resource.mq_level.present?
              div do
                "#{resource.mq_level} (#{resource.mq_status})"
              end
            end
          end
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
            resource.mq_assessments.latest_first.map do |a|
              panel "Assessement taken on #{a.assessment_date}", class: 'mq_assessment' do
                attributes_table_for a do
                  row :level, &:status_description_short
                  row :publication_date do
                    a.publication_date.strftime('%B %Y')
                  end
                  row :assessment_date
                end

                table_for a.questions do
                  column :level do |q|
                    q['level']
                  end
                  column :answer do |q|
                    q['answer']
                  end
                  column :question do |q|
                    q['question']
                  end
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
            resource.cp_assessments.latest_first.map do |a|
              div class: 'panel benchmark' do
                attributes_table_for a do
                  row :publication_date do
                    a.publication_date.strftime('%B %Y')
                  end
                  row :assessment_date
                  row :assumptions
                end

                if a.emissions.present?
                  table class: 'table cell-padding-sm cell-centered' do
                    thead do
                      a.emissions_all_years.map do |year|
                        th year
                      end
                    end
                    tbody do
                      tr do
                        a.emissions_all_years.map do |year|
                          td do
                            a.emissions[year] || 'N/A'
                          end
                        end
                      end
                    end
                  end
                else
                  div class: 'padding-20' do
                    'No emission or target values for this assessment'
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  index do
    column :name do |company|
      link_to company.name, admin_company_path(company)
    end
    column :isin
    column :size do |company|
      company.size.humanize
    end
    column :level, &:mq_status_description_short
    column :location
    column :headquarter_location
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      columns do
        column { f.input :name }
        column { f.input :isin }
      end

      columns do
        column { f.input :sector }
        column { f.input :size, as: :select, collection: array_to_select_collection(Company::SIZES) }
      end

      columns do
        column { f.input :location }
        column { f.input :headquarter_location }
      end

      f.input :ca100
    end

    f.actions
  end

  controller do
    def scoped_collection
      super.includes(:location, :headquarter_location, :mq_assessments)
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
