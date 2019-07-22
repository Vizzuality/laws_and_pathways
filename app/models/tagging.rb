# == Schema Information
#
# Table name: taggings
#
#  id            :bigint           not null, primary key
#  tag_id        :bigint
#  taggable_type :string
#  taggable_id   :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
end
