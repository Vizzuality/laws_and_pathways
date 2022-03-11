FactoryBot.define do
  factory :data_upload do
    uploader { 'Companies' }
    file { TestFiles.csv }
    association :uploaded_by, factory: :admin_user
  end
end
