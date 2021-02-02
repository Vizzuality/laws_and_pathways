require 'rails_helper'

RSpec.describe Admin::TPISectorsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let(:cluster) { create(:tpi_sector_cluster) }
  let_it_be(:sector) { create(:tpi_sector, :with_benchmarks) }
  let(:valid_attributes) {
    attributes_for(
      :tpi_sector,
      name: 'Sector Name',
      cluster_id: cluster.id,
      cp_units_attributes: [
        attributes_for(:cp_unit),
        attributes_for(:cp_unit, valid_since: 3.days.ago)
      ]
    )
  }
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
      subject { post :create, params: {tpi_sector: valid_attributes} }

      it 'creates a new Sector' do
        expect { subject }.to change(TPISector, :count).by(1)

        last_sector_created.tap do |s|
          expect(s.name).to eq('Sector Name')
          expect(s.cluster_id).to eq(cluster.id)
        end
      end

      it 'creates a new CP::Units' do
        expect { subject }.to change(CP::Unit, :count).by(2)
      end

      it 'redirects to the created Sector' do
        expect(subject).to redirect_to(admin_tpi_sector_path(last_sector_created))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {tpi_sector: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Sector' do
        expect { subject }.not_to change(TPISector, :count)
      end
    end
  end

  def last_sector_created
    TPISector.order(:created_at).last
  end
end
