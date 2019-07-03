# == Schema Information
#
# Table name: taggings
#
#  id            :bigint(8)        not null, primary key
#  tag_id        :bigint(8)
#  taggable_type :string
#  taggable_id   :bigint(8)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
end
