# == Schema Information
#
# Table name: events
#
#  id             :bigint           not null, primary key
#  eventable_type :string
#  eventable_id   :bigint
#  title          :string           not null
#  event_type     :string           not null
#  date           :date             not null
#  url            :text
#  description    :text
#  discarded_at   :datetime
#

class Event < ApplicationRecord
  include DiscardableModel

  belongs_to :eventable, polymorphic: true

  validates_presence_of :title, :date
  validates :date, date_after: Date.new(1900, 1, 1)
  validates :url, url: true

  validates :event_type, presence: true, inclusion: {in: :event_types}

  def event_types
    return [] unless eventable_type.present?

    eventable_type.constantize.const_get(:EVENT_TYPES)
  rescue NameError
    raise "please define EVENT_TYPES const in #{eventable_type.class.name}"
  end
end
