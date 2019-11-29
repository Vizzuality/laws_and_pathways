# == Schema Information
#
# Table name: contents
#
#  id           :bigint           not null, primary key
#  title        :string
#  text         :text
#  page_id      :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  content_type :string
#

require 'rails_helper'

RSpec.describe Content, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
