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

  data_export_sidebar 'MQ Assessments'

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

    column(:company) { |a| a.company.name }
    column :assessment_date
    column :publication_date
    column :level

    question_column_names.map do |question_column|
      column question_column, humanize_name: false do |a|
        answer = a.questions_by_key_hash[question_column]
        if answer.present?
          answer['answer']
        else
          'not applicable for this methodology'
        end
      end
    end
  end

  controller do
    def scoped_collection
      super.includes(:company)
    end
  end
end
