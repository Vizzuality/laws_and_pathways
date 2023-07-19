require 'rails_helper'

# rubocop:disable Layout/LineLength
RSpec.describe TPI::SitemapsController, type: :controller do
  let_it_be(:company1) { create(:company, :published) }
  let_it_be(:company2) { create(:company, :draft) }
  let_it_be(:bank) { create(:bank) }
  let_it_be(:page1) { create(:tpi_page) }
  let_it_be(:publication1) { create(:publication, :published) }
  let_it_be(:publication2) { create(:publication, :not_published) }
  let_it_be(:article1) { create(:news_article, :published) }
  let_it_be(:article2) { create(:news_article, :not_published) }

  let(:host_params) { {host: 'tpi.localhost', protocol: :https} }

  before(:each) do
    @request.host = 'tpi.localhost'
  end

  describe 'GET sitemap xml' do
    subject { get :index, format: :xml }

    it { is_expected.to be_successful }

    it('should return all published entities') do
      subject
      expect(response.body).to have_css('url loc', text: tpi_company_url(company1.slug, **host_params))
      expect(response.body).to have_css('url loc', text: tpi_bank_url(bank.slug, **host_params))
      expect(response.body).to have_css('url loc', text: "https://#{host_params[:host]}/#{page1.slug}")
      expect(response.body).to have_css('url loc', text: tpi_publication_download_file_path(slug: publication1.slug, **host_params))
      expect(response.body).to have_css('url loc', text: tpi_publication_url(article1, type: 'NewsArticle', **host_params))
    end

    it('should not return unpublished entities') do
      subject
      expect(response.body).not_to have_css('url loc', text: tpi_company_url(company2.slug, **host_params))
      expect(response.body).not_to have_css('url loc', text: tpi_publication_download_file_path(slug: publication2.slug, **host_params))
      expect(response.body).not_to have_css('url loc', text: tpi_publication_url(article2, type: 'NewsArticle', **host_params))
    end
  end
end
# rubocop:enable Layout/LineLength
