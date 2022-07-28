# == Schema Information
#
# Table name: data_uploads
#
#  id             :bigint           not null, primary key
#  uploaded_by_id :bigint
#  uploader       :string           not null
#  details        :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
FactoryBot.define do
  factory :data_upload do
    uploader { 'Companies' }
    file { TestFiles.csv }
    association :uploaded_by, factory: :admin_user
  end
end
