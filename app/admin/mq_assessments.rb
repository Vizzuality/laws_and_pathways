ActiveAdmin.register MQ::Assessment do
  config.sort_order = 'publication_date_desc'

  menu parent: 'TPI', priority: 1, label: 'Management Quality Assessments'

  decorate_with MQ::AssessmentDecorator

  actions :all, except: [:new, :edit, :create, :update]

  filter :assessment_date
  filter :publication_date, as: :select, collection: proc { MQ::Assessment.all_publication_dates }
  filter :company
  filter :company_sector_id, as: :select, collection: proc { Sector.all }
  filter :level, as: :select, collection: MQ::Assessment::LEVELS

  sidebar 'Export / Import', if: -> { collection.any? }, only: :index do
    ul do
      publication_date_selected = request.query_parameters.dig(:q, :publication_date_eq)

      li do
        if publication_date_selected
          link_to "Download MQ Assessments (#{publication_date_selected})",
                  params: request.query_parameters.except(:commit, :format),
                  format: 'csv'
        else
          para 'Please filter by publication date to be able to download CSV file'
        end
      end

      li do
        upload_label = '<strong>Upload</strong> MQ Assessments'.html_safe
        upload_path = new_admin_data_upload_path(data_upload: {uploader: 'MQAssessments'})

        link_to upload_label, upload_path
      end
    end
    hr
  end

  show do
    attributes_table do
      row :id
      row :company
      row :level, &:level_tag
      row :assessment_date
      row :publication_date
      row :notes
      row :created_at
      row :updated_at
    end

    panel 'Questions' do
      table_for resource.questions do
        column :number
        column :level
        column :answer
        column :question
      end
    end

    active_admin_comments
  end

  index do
    column :title, &:title_link
    column :assessment_date
    column :publication_date
    column :level, &:level_tag
    actions
  end

  csv do
    column :id
    column(:company) { |a| a.company.name }
    column :assessment_date
    column :publication_date, &:publication_date_csv
    column :level
    column :notes

    # we can take first assessment questions "schema"
    # since it is already filtered by publication date
    collection.first.questions.map do |mq_question|
      column mq_question.csv_column_name, humanize_name: false do |assessment|
        assessment.find_answer_by_key(mq_question.key)
      end
    end
  end

  controller do
    def scoped_collection
      super.includes(:company)
    end
  end
end
