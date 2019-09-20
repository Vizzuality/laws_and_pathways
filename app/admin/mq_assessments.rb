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
        upload_label = "<strong>Upload</strong> MQ Assessments".html_safe
        upload_path = new_admin_data_upload_path(data_upload: {uploader: 'MQAssessment'})

        link_to upload_label, upload_path
      end
    end
    hr
  end

  show do
    attributes_table do
      row :id
      row :company
      row :level, &:status_description_short
      row :assessment_date
      row :publication_date
      row :notes
      row :created_at
      row :updated_at
    end

    panel 'Questions' do
      table_for resource.questions do
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

  index do
    column :title, &:title_link
    column :assessment_date
    column :publication_date
    column :level, &:status_description_short
    actions
  end

  csv do
    question_column_names = collection.flat_map(&:all_questions_keys).uniq

    column :id
    column(:company) { |a| a.company.name }
    column :assessment_date
    column :publication_date
    column :level

    question_column_names.map do |question_column|
      column question_column, humanize_name: false do |a|
        a.questions_by_key_hash[question_column]['answer']
      end
    end
  end

  controller do
    def scoped_collection
      super.includes(:company)
    end
  end
end
