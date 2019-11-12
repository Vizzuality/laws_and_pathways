ActiveAdmin.register_page 'Dashboard' do
  menu priority: 0, label: 'Dashboard'

  content do
    if ActiveAdmin::Comment.any?
      h1 'Latest Comments'
      div class: 'index_content' do
        div class: 'index_as_table' do
          table_for ActiveAdmin::Comment.order(created_at: :desc).limit(20),
                    class: 'index_table index' do
            column :resource
            column :body do |comment|
              simple_format comment.body
            end
            column :author
            column :created_at
          end
        end
      end
    else
      div class: 'blank_slate_container' do
        span class: 'blank_slate' do
          span 'No recent comments! All is good.'
        end
      end
    end
  end
end
