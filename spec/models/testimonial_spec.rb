# == Schema Information
#
# Table name: testimonials
#
#  id         :bigint           not null, primary key
#  quote      :string
#  author     :string
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Testimonial, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
