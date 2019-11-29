# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  link       :string
#  content_id :bigint           not null
#

class Image < ApplicationRecord
  belongs_to :content
  has_one_attached :logo
end
