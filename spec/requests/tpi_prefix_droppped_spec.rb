require 'rails_helper'

RSpec.describe 'tpi prefix dropped', type: :request do
  let(:company) { create(:company, :published) }
  let(:page) { create(:tpi_page) }

  before(:each) do
    host! 'tpi.localhost'
  end

  it 'redirects to company page' do
    get "/tpi/companies/#{company.slug}"
    expect(response).to redirect_to("/companies/#{company.slug}")
  end

  it 'redirects to sectors page' do
    get '/tpi/sectors'
    expect(response).to redirect_to('/sectors')
  end

  it 'redirects to sector page' do
    url_part = "sectors/#{company.sector.slug}"

    get "/tpi/#{url_part}"
    expect(response).to redirect_to("/#{url_part}")
  end

  it 'redirects to tpi page' do
    url_part = page.slug

    get "/tpi/#{url_part}"
    expect(response).to redirect_to("/#{url_part}")
  end
end
