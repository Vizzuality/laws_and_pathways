class CP::Matrix < ApplicationRecord
  belongs_to :cp_assessment, class_name: 'CP::Assessment'

  validates :portfolio, inclusion: {in: CP::Portfolio::NAMES, allow_blank: true}, presence: true

  with_options allow_nil: true, allow_blank: true, inclusion: {in: CP::Alignment::ALLOWED_NAMES} do
    validates :cp_alignment_2025
    validates :cp_alignment_2035
    validates :cp_alignment_2050
  end
end
