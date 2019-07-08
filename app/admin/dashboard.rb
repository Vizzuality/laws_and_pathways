ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: 'Dashboard'

  content do
    div class: 'blank_slate_container' do
      span class: 'blank_slate' do
        span 'Laws and Pathways dashboard'
      end
    end
  end
end
