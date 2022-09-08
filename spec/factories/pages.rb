# == Schema Information
#
# Table name: pages
#
#  id          :bigint           not null, primary key
#  title       :string
#  description :text
#  slug        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  menu        :string
#  type        :string
#  position    :integer
#

FactoryBot.define do
  factory :page do
    sequence(:title) { |n| 'title -' + ('AA'..'ZZ').to_a[n] }
    description { 'MyText' }

    factory :tpi_page do
      menu { TPIPage::MENU_HEADERS.sample }
      type { 'TPIPage' }
    end

    factory :cclow_page do
      menu { CCLOWPage::MENU_HEADERS.sample }
      type { 'CCLOWPage' }
    end
  end
end
