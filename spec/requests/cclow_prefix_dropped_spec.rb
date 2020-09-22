require 'rails_helper'

RSpec.describe 'cclow prefix dropped', type: :request do
  let(:geography) { create(:geography, :published) }
  let(:legislation) { create(:legislation, :published) }
  let(:litigation) { create(:litigation, :published) }
  let(:target) { create(:target, :published) }
  let(:page) { create(:cclow_page) }

  before(:each) do
    host! 'cclow.localhost'
  end

  it 'redirects to geography page' do
    get "/cclow/geographies/#{geography.slug}"
    expect(response).to redirect_to("/geographies/#{geography.slug}")
  end

  it 'redirects to litigation page' do
    url_part = "#{litigation.geography.slug}/litigation_cases/#{litigation.slug}"

    get "/cclow/#{url_part}"
    expect(response).to redirect_to("/#{url_part}")
  end

  it 'redirects to legislation page' do
    url_part = "#{legislation.geography.slug}/#{legislation.law? ? 'laws' : 'policies'}/#{legislation.slug}"

    get "/cclow/#{url_part}"
    expect(response).to redirect_to("/#{url_part}")
  end

  it 'redirects to targets page' do
    url_part = "#{target.geography.slug}/climate_targets"

    get "/cclow/#{url_part}"
    expect(response).to redirect_to("/#{url_part}")
  end

  it 'redirects to specific sector targets page' do
    url_part = "#{target.geography.slug}/climate_targets/#{target.sector.name}"

    get "/cclow/#{url_part}"
    expect(response).to redirect_to("/#{url_part}")
  end

  it 'redirects to cclow page' do
    url_part = page.slug

    get "/cclow/#{url_part}"
    expect(response).to redirect_to("/#{url_part}")
  end
end
