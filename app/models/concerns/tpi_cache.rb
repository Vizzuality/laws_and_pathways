module TPICache
  KEY = 'tpi_sectors_companies_market_cap'.freeze

  extend ActiveSupport::Concern

  included do
    after_commit :clear_tpi_cache
  end

  def clear_tpi_cache
    Rails.cache.delete(KEY)
  end
end
