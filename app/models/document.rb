# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  name              :string
#  external_url      :text
#  language          :string
#  last_verified_on  :date
#  documentable_type :string
#  documentable_id   :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Document < ApplicationRecord
end
