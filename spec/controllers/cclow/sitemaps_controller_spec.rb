require 'rails_helper'

# rubocop:disable Layout/LineLength
RSpec.describe CCLOW::SitemapsController, type: :controller do
  let_it_be(:geography1) { create(:geography, :published, name: 'Poland', iso: 'POL') }
  let_it_be(:geography2) { create(:geography, :published, name: 'Germany', iso: 'GER') }
  let_it_be(:geography3) { create(:geography, :draft, name: 'Spain', iso: 'ESP') }
  let_it_be(:litigation1) { create(:litigation, :published, geography: geography1) }
  let_it_be(:litigation2) { create(:litigation, :draft, geography: geography1) }
  let_it_be(:litigation3) { create(:litigation, :published, geography: geography2) }
  let_it_be(:legislation1) { create(:legislation, :law, :published, geography: geography2) }
  let_it_be(:legislation2) { create(:legislation, :policy, :published, geography: geography2) }
  let_it_be(:legislation3) { create(:legislation, :policy, :draft, geography: geography2) }

  let(:host_params) { {host: 'cclow.localhost', protocol: :https} }

  before(:each) do
    @request.host = 'cclow.localhost'
  end

  describe 'GET sitemap xml' do
    subject { get :index, format: :xml }

    it { is_expected.to be_successful }

    it('should return all published entities') do
      subject
      expect(response.body).to have_css('url loc', text: cclow_geography_url(geography1.slug, **host_params))
      expect(response.body).to have_css('url loc', text: cclow_geography_url(geography2.slug, **host_params))

      expect(response.body).to have_css('url loc', text: cclow_geography_litigation_case_url(geography1.slug, litigation1.slug, **host_params))
      expect(response.body).to have_css('url loc', text: cclow_geography_litigation_case_url(geography2.slug, litigation3.slug, **host_params))

      expect(response.body).to have_css('url loc', text: cclow_geography_law_url(geography2.slug, legislation1.slug, **host_params))
      expect(response.body).to have_css('url loc', text: cclow_geography_policy_url(geography2.slug, legislation2.slug, **host_params))
    end

    it('should not return unpublished entities') do
      subject
      expect(response.body).not_to have_css('url loc', text: cclow_geography_url(geography3.slug, **host_params))
      expect(response.body).not_to have_css('url loc', text: cclow_geography_litigation_case_url(geography1.slug, litigation2.slug, **host_params))
      expect(response.body).not_to have_css('url loc', text: cclow_geography_policy_url(geography3.slug, legislation3.slug, **host_params))
    end
  end
end
# rubocop:enable Layout/LineLength
