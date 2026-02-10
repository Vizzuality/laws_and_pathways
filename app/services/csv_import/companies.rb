module CSVImport
  class Companies < BaseImporter
    include Helpers

    BATCH_SIZE = 500

    # rubocop:disable Layout/LineLength
    def import
      preload_caches

      new_companies = []

      import_each_csv_row(csv) do |row|
        company = prepare_company_cached(row)

        company.name = row[:name] if row.header?(:name)
        company.isin = row[:isin] if row.header?(:isin)
        company.sector = cached_sector(row[:sector]) if row.header?(:sector)
        company.market_cap_group = row[:market_cap_group].downcase if row.header?(:market_cap_group)
        company.sedol = row[:sedol].presence if row.header?(:sedol)
        company.geography = @geo_cache[row[:geography_iso]&.upcase] if row.header?(:geography_iso)
        company.headquarters_geography = @geo_cache[row[:headquarters_geography_iso]&.upcase] if row.header?(:headquarters_geography_iso)
        company.latest_information = row[:latest_information].presence if row.header?(:latest_information)
        company.company_comments_internal = row[:company_comments_internal].presence if row.header?(:company_comments_internal)
        company.permid = row[:permid].presence if row.header?(:permid)
        company.ca100 = row[:ca100] || false if row.header?(:ca100)
        company.mq_focus_company = row[:mq_focus_company] || false if row.header?(:mq_focus_company)
        company.active = row[:active] || true if row.header?(:active)
        company.visibility_status = row[:visibility_status]&.downcase if row.header?(:visibility_status)

        was_new_record = company.new_record?
        any_changes = company.changed?

        if was_new_record
          assign_slug(company)
          assign_defaults(company)
          validate_for_bulk!(company)
          new_companies << company
        elsif any_changes
          company.save!
        end

        update_import_results(was_new_record, any_changes)
      end

      bulk_insert(new_companies) if new_companies.any?
      clear_tpi_caches
    end
    # rubocop:enable Layout/LineLength

    private

    def resource_klass
      Company
    end

    def required_headers
      [:id]
    end

    def preload_caches
      companies = Company.pluck(:id, :isin, :name, :slug)
      @id_lookup = {}
      @isin_lookup = {}
      @name_lookup = {}
      @used_slugs = Set.new

      companies.each do |id, isin, name, slug|
        @id_lookup[id.to_s] = id
        @isin_lookup[isin.strip] = id if isin.present?
        @name_lookup[name.strip.downcase] = id if name.present?
        @used_slugs.add(slug) if slug.present?
      end

      @geo_cache = Geography.all.index_by { |g| g.iso&.upcase }
      @sector_cache = {}
      TPISector.all.each { |s| @sector_cache[s.name.strip.downcase] = s }
    end

    def prepare_company_cached(row)
      return prepare_overridden_resource(row) if override_id

      id = row[:id].present? ? @id_lookup[row[:id].strip] : nil
      id ||= row[:isin].present? ? @isin_lookup[row[:isin].strip] : nil
      id ||= row[:name].present? ? @name_lookup[row[:name].strip.downcase] : nil

      id ? Company.find(id) : Company.new
    end

    def cached_sector(sector_name)
      return unless sector_name.present?

      key = sector_name.strip.downcase
      @sector_cache[key] ||= begin
        TPISector.where('lower(name) = ?', key).first ||
          TPISector.create!(name: sector_name.strip, categories: [Company.to_s])
      end
    end

    def assign_slug(company)
      base = company.name.parameterize
      slug = base
      n = 2
      while @used_slugs.include?(slug)
        slug = "#{base}-#{n}"
        n += 1
      end
      company.slug = slug
      @used_slugs.add(slug)
    end

    def assign_defaults(company)
      company.visibility_status ||= 'draft'
      company.ca100 = false if company.ca100.nil?
      company.mq_focus_company = false if company.mq_focus_company.nil?
      company.active = true if company.active.nil?
      now = Time.current
      company.created_at = now
      company.updated_at = now
    end

    def validate_for_bulk!(company)
      missing = []
      missing << 'name' if company.name.blank?
      missing << 'isin' if company.isin.blank?
      missing << 'market_cap_group' if company.market_cap_group.blank?
      if missing.any?
        company.errors.add(:base, "Missing required fields: #{missing.join(', ')}")
        raise ActiveRecord::RecordInvalid, company
      end
    end

    def bulk_insert(companies)
      Company.import(companies, batch_size: BATCH_SIZE, validate: false, timestamps: false)
      create_friendly_slugs(companies)
    end

    def create_friendly_slugs(companies)
      now = Time.current
      slugs = companies.filter_map do |c|
        next unless c.id.present? && c.slug.present?

        FriendlyId::Slug.new(
          slug: c.slug,
          sluggable_type: 'Company',
          sluggable_id: c.id,
          created_at: now
        )
      end
      FriendlyId::Slug.import(slugs, batch_size: BATCH_SIZE, validate: false) if slugs.any?
    end

    def clear_tpi_caches
      Rails.cache.delete(TPICache::KEY)
      Rails.cache.delete("#{TPICache::KEY}-mq-beta-scores-true")
      Rails.cache.delete("#{TPICache::KEY}-mq-beta-scores-false")
    end
  end
end
