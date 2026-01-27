module TPI
  class IndustriesController < TPIController
    include UserDownload

    before_action :enable_beta_mq_assessments
    before_action :fetch_industry, only: [:show, :levels_chart_data, :cp_performance_chart_data, :user_download_cp, :user_download_mq]
    before_action :fetch_companies, only: [:show]
    before_action :fetch_sectors, only: [:show]
    before_action :fetch_industries, only: [:show]

    def show
      @industry_sectors = @industry.tpi_sectors.tpi_tool.includes(:cluster).order(:name)
      @industry_sector_ids = @industry_sectors.pluck(:id)
      @industry_companies = @companies.select { |c| @industry_sector_ids.include?(c.sector_id) }

      @companies_by_levels = ::Api::Charts::Sector.new(
        companies_scope, enable_beta_mq_assessments: session[:enable_beta_mq_assessments]
      ).companies_summaries_by_level

      @companies_by_sectors = ::Api::Charts::Sector.new(
        companies_scope, enable_beta_mq_assessments: session[:enable_beta_mq_assessments]
      ).companies_market_cap_by_sector

      @publications_and_articles = publications_and_articles

      fixed_navbar("Industry #{@industry.name}", admin_industry_path(@industry))
    end

    def levels_chart_data
      data = ::Api::Charts::Sector.new(
        companies_scope, enable_beta_mq_assessments: session[:enable_beta_mq_assessments]
      ).companies_count_by_level

      render json: data.chart_json
    end

    def cp_performance_chart_data
      sector_ids = @industry.tpi_sectors.tpi_tool.pluck(:id)
      data = ::Api::Charts::CPPerformance.new.cp_performance_for_sectors(sector_ids)

      render json: data.chart_json
    end

    def user_download_cp
      send_cp_user_download_file(
        industry_companies_ids,
        "TPI Carbon Performance data - #{@industry.name}"
      )
    end

    def user_download_mq
      send_mq_user_download_file(
        industry_companies_ids,
        "TPI Management Quality data - #{@industry.name}"
      )
    end

    private

    def industry_companies_ids
      sector_ids = @industry.tpi_sectors.tpi_tool.pluck(:id)
      Company.published.where(sector_id: sector_ids).select(:id)
    end

    def send_cp_user_download_file(companies_ids, filename)
      cp_assessments = CP::Assessment
        .currently_published
        .companies
        .where(cp_assessmentable_id: companies_ids)
        .joins(:company)
        .order('companies.name ASC, assessment_date DESC')
        .includes(company: [:geography, sector: [:cp_units]])

      send_tpi_cp_file(
        cp_assessments: cp_assessments,
        filename: filename
      )
    end

    def send_mq_user_download_file(companies_ids, filename)
      mq_assessments = MQ::Assessment
        .currently_published
        .where(company_id: companies_ids)
        .joins(:company)
        .order('companies.name ASC, publication_date DESC, methodology_version DESC, assessment_date DESC')
        .includes(company: [:geography, { sector: :industries }])

      send_tpi_mq_file(
        mq_assessments: mq_assessments,
        filename: filename
      )
    end

    def fetch_industry
      @industry = Industry.friendly.find(params[:id])
    end

    def fetch_sectors
      @sectors = TPISector.tpi_tool.with_companies.includes(:cluster).order(:name)
      @sectors_json = @sectors.map { |s| s.as_json(except: [:created_at, :updated_at], methods: [:path]) }
      @industry_sectors_json = @industry.tpi_sectors.tpi_tool.includes(:cluster).order(:name)
        .map { |s| s.as_json(except: [:created_at, :updated_at], methods: [:path]) }
    end

    def fetch_industries
      @industries = Industry.joins(:tpi_sectors)
        .where(tpi_sectors: {id: TPISector.tpi_tool.with_companies.pluck(:id)})
        .distinct
        .order(:name)
      @industries_json = @industries.map do |i|
        {
          id: i.id,
          name: i.name,
          slug: i.slug,
          path: tpi_corporate_industry_path(i.slug)
        }
      end
    end

    def fetch_companies
      @companies = Company
        .published
        .joins(:sector)
        .select(:id, :name, :slug, :sector_id, 'tpi_sectors.name as sector_name', :active)
        .order('tpi_sectors.name', :name)
    end

    def companies_scope
      sector_ids = @industry.tpi_sectors.tpi_tool.pluck(:id)
      Company.published.active.with_latest_mq_v5.where(sector_id: sector_ids).order(name: :asc)
    end

    def publications_and_articles
      sector_names = @industry.tpi_sectors.tpi_tool.pluck(:name).join(',')
      return [] if sector_names.blank?

      Queries::TPI::NewsPublicationsQuery.new(
        sectors: sector_names,
        tags: 'State of Transition,Carbon Performance,Publicly listed companies,Public consultations'
      ).call.take(3)
    end
  end
end
