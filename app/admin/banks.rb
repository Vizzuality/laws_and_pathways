ActiveAdmin.register Bank do
  menu priority: 0, parent: 'TPI'

  decorate_with BankDecorator

  config.sort_order = 'name_asc'
  config.batch_actions = false

  permit_params :name, :isin, :geography_id,
                :market_cap_group, :sedol

  filter :isin_contains, label: 'ISIN'
  filter :name_contains, label: 'Name'
  filter :geography
  filter :created_at
  filter :market_cap_group,
         as: :check_boxes,
         collection: proc { array_to_select_collection(Bank::MARKET_CAP_GROUPS) }

  data_export_sidebar 'Banks'

  # sidebar 'Details', only: :show do
  #   attributes_table do
  #     row :company, &:name
  #     row :active, &:active
  #     row :level, &:mq_level_tag
  #     row :updated_at
  #   end
  # end

  # action_item :preview, priority: 0, only: :show do
  #   link_to 'Preview', resource.preview_url if resource.published?
  # end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :name
          row :slug
          row :isin, &:isin_as_tags
          row :sedol
          row :geography
          row :market_cap_group
          row :created_at
          row :updated_at
        end
      end

      tab :bank_assessments do
        panel 'Bank Assessments' do
          if resource.assessments.empty?
            div class: 'padding-20' do
              'No Assessments for this bank yet'
            end
          else
            resource.assessments.decorate.map do |a|
              panel a.title_link, class: 'bank_assessment' do
                attributes_table_for a do
                  row :assessment_date
                end

                table_for a.results do
                  column(:number) { |r| r.indicator.number }
                  column(:display_text) { |r| r.indicator.display_text }
                  column(:value) { |r| r.percentage || r.answer }
                end
              end
            end
          end
        end
      end
    end

    active_admin_comments
  end

  index do
    column(:name) { |bank| link_to bank.name, admin_bank_path(bank) }
    column :geography

    actions
  end

  csv do
    column :id
    column :name
    column(:geography_iso) { |c| c.geography.iso }
    column(:geography) { |c| c.geography.name }
    column :isin
    column :sedol
    column :market_cap_group
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      columns do
        column { f.input :name }
        column { f.input :geography }
        column do
          f.input :market_cap_group, as: :select, collection: array_to_select_collection(Bank::MARKET_CAP_GROUPS)
        end
      end

      columns do
        column { f.input :isin, as: :tags }
        column { f.input :sedol }
      end
    end

    f.actions
  end

  controller do
    def scoped_collection
      super.includes(:geography)
    end
  end
end
