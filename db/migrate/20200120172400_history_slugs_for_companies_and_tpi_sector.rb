class HistorySlugsForCompaniesAndTPISector < ActiveRecord::Migration[6.0]
  def up
    TPISector.find_each do |sector|
      FriendlyId::Slug.find_or_create_by(sluggable: sector, slug: sector.slug)
    end

    Company.find_each do |company|
      FriendlyId::Slug.find_or_create_by(sluggable: company, slug: company.slug)
    end
  end

  def down

  end
end
