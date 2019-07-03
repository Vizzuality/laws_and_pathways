ActiveAdmin.register Company do
  permit_params :name, :isin, :sector_id, :location_id, :headquarter_location_id, :ca100,
                :size

  filter :isin_contains, label: 'ISIN'
  filter :name_contains, label: 'Name'
  filter :location
  filter :headquarter_location
  filter :size, as: :check_boxes, collection: array_to_select_collection(Company::SIZES)

  config.batch_actions = false

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :isin
      row :location
      row :headquarter_location
      row :ca100
      row :size
      row 'Management Quality Level' do
        return unless resource.mq_level.present?

        div do
          "#{resource.mq_level} (#{resource.mq_status})"
        end
      end
      row :created_at
      row :updated_at
    end

    panel 'Management Quality Assessments' do
      if resource.mq_assessments.empty?
        'No Management Quality Assessments for this company yet'
      else
        table_for resource.mq_assessments.latest_first do
          column :publication_date
          column :assessment_date
          column :level
          column :questions do |c|
            div do
              c.questions.map.with_index do |q, index|
                div do
                  "#{index + 1}. ".html_safe << q['question'].html_safe << '  '.html_safe <<
                    content_tag(:strong, q['answer'])
                end
              end
            end
          end
          column 'Actions' do |c|
            div class: 'table_actions' do
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
