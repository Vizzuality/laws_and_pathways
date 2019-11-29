# == Schema Information
#
# Table name: news_articles
#
#  id               :bigint           not null, primary key
#  title            :string
#  content          :text
#  publication_date :date
#  created_by_id    :bigint
#  updated_by_id    :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  article_type     :string
#

require 'rails_helper'

RSpec.describe NewsArticle, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
