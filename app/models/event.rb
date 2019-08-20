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
#

class Event < ApplicationRecord
  belongs_to :eventable, polymorphic: true

  validates_presence_of :title, :date
  validates :url, url: true

  validates :event_type, presence: true, inclusion: {in: :valid_types}

  def valid_types
    return Litigation::EVENT_TYPES if eventable.is_a?(Litigation)

    []
  end
end
