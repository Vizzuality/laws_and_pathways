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

class DataUpload < ApplicationRecord
  has_one_attached :file

  DEV_UPLOADERS = Rails.env.development? || Rails.env.test? ? %w[Documents] : []
  UPLOADERS = (%w[
    CPAssessments
    CPBenchmarks
    Companies
    Events
    ExternalLegislations
    Geographies
    Legislations
    LitigationSides
    Litigations
    MQAssessments
    Targets
  ] + DEV_UPLOADERS).freeze

  belongs_to :uploaded_by, class_name: 'AdminUser', optional: true

  validates :file, attached: true, content_type: {in: ['text/csv', 'application/vnd.ms-excel']}
  validates :uploader, inclusion: {in: UPLOADERS}

  before_create :set_uploaded_by

  def uploaded_at
    created_at
  end

  def to_s
    "#{uploader} upload - id: #{id}"
  end

  private

  def set_uploaded_by
    self.uploaded_by = Current.admin_user
    true
  end
end
