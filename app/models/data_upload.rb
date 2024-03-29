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

  DEV_UPLOADERS = %w[Documents].freeze
  UPLOADERS = {
    'ASCOR Countries' => 'ASCORCountries',
    'ASCOR Benchmarks' => 'ASCORBenchmarks',
    'ASCOR Pathways' => 'ASCORPathways',
    'ASCOR Assessment Indicators' => 'ASCORAssessmentIndicators',
    'ASCOR Assessments' => 'ASCORAssessments',
    'Banks' => 'Banks',
    'Bank Assessment Indicators' => 'BankAssessmentIndicators',
    'Bank Assessments' => 'BankAssessments',
    'Company Carbon Performance Assessments' => 'CompanyCPAssessments',
    'Company Carbon Performance Benchmarks' => 'CompanyCPBenchmarks',
    'Bank Carbon Performance Benchmarks' => 'BankCPBenchmarks',
    'Bank Carbon Performance Assessments 2025' => 'BankCPAssessments2025',
    'Bank Carbon Performance Assessments 2035' => 'BankCPAssessments2035',
    'Bank Carbon Performance Assessments 2050' => 'BankCPAssessments2050',
    'Companies' => 'Companies',
    'Documents' => 'Documents',
    'Events' => 'Events',
    'External Legislations' => 'ExternalLegislations',
    'Geographies' => 'Geographies',
    'Legislations' => 'Legislations',
    'Litigation Sides' => 'LitigationSides',
    'Litigations' => 'Litigations',
    'Management Quality Assessments' => 'MQAssessments',
    'Targets' => 'Targets'
  }.reject { |k| !(Rails.env.test? || Rails.env.development?) && DEV_UPLOADERS.include?(k) }.freeze

  belongs_to :uploaded_by, class_name: 'AdminUser', optional: true

  validates :file, attached: true, content_type: {in: ['text/csv', 'text/plain', 'application/vnd.ms-excel']}
  validates :uploader, inclusion: {in: UPLOADERS.values}

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
