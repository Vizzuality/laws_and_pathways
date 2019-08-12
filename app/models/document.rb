# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  type              :string           not null
#  external_url      :text
#  language          :string
#  last_verified_on  :date
#  documentable_type :string
#  documentable_id   :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Document < ApplicationRecord
  self.inheritance_column = nil

  TYPES = %w[uploaded external].freeze
  enum type: array_to_enum_hash(TYPES)

  belongs_to :documentable, polymorphic: true

  has_one_attached :file

  before_create :set_last_verified_on

  validates :external_url, url: true, presence: true, if: :external?
  validates :file, attached: true, if: :uploaded?

  validates_presence_of :name, :type

  def url
    return file_url if uploaded?

    external_url
  end

  def external?
    !uploaded?
  end

  private

  def file_url
    return unless file.attached?

    Rails.application.routes.url_helpers.polymorphic_url(file, only_path: true)
  end

  def set_last_verified_on
    self.last_verified_on = Time.zone.now.to_date
  end
end
