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
  validates :url, url: true

  validates :event_type, presence: true, inclusion: {in: :event_types}

  def event_types
    return [] unless eventable.present?

    eventable.class.const_get(:EVENT_TYPES)
  rescue NameError
    raise "please define EVENT_TYPES const in #{eventable.class.name}"
  end
end
