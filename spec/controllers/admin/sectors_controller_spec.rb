require 'rails_helper'

RSpec.describe Admin::SectorsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:sector) { create(:sector, :with_benchmarks) }
  let(:valid_attributes) { attributes_for(:sector) }
  let(:invalid_attributes) { valid_attributes.merge(name: nil) }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    before(:example) do
      get :show, params: {id: sector.id}
    end

    it 'should be successful' do
      expect(response).to be_successful
    end

    it 'should show sector benchmarks' do
      benchmarks = sector
        .cp_benchmarks
        .by_release_date
        .group_by(&:release_date)
        .values
        .last

      expect(page).to have_selector '#cp-benchmarks .panel.benchmark',
                                    count: sector.cp_benchmarks.count
      latest_benchmarks = page.find('#cp-benchmarks .panel.benchmark:nth-child(1) table tbody')
      expect(latest_benchmarks).to have_selector 'tr', count: benchmarks.length
      expect(latest_benchmarks).to have_selector 'tr:nth-child(1) td:nth-child(1)', text: benchmarks[0].scenario
    end
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: sector.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {sector: valid_attributes} }

      it 'creates a new Sector' do
        expect { subject }.to change(Sector, :count).by(1)
      end

      it 'redirects to the created Sector' do
        expect(subject).to redirect_to(admin_sector_path(Sector.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {sector: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Sector' do
        expect { subject }.not_to change(Sector, :count)
      end
    end
  end
end
