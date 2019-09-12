require 'rails_helper'

RSpec.describe Admin::TargetsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:target) { create(:target, year: 2030) }
  let!(:target2) { create(:target, year: 2040) }
  let!(:target3) { create(:target, year: 2050) }
  let(:sector) { create(:sector) }
  let(:geography) { create(:geography) }
  let(:target_scope) { create(:target_scope) }
  let(:legislations) { create_list(:legislation, 2) }
  let(:valid_attributes) {
    attributes_for(
      :target,
      legislation_ids: legislations.pluck(:id),
      geography_id: geography.id,
      sector_id: sector.id,
      target_scope_id: target_scope.id
    )
  }
  let(:invalid_attributes) { valid_attributes.merge(ghg_target: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET index with .csv format' do
    before :each do
      get :index, format: 'csv'
    end

    it('returns CSV file') do
      expect(response.header['Content-Type']).to include('text/csv')
    end

    it('returns all targets') do
      csv = response_as_csv

      expect(csv.by_col[0].sort).to eq([target.id, target2.id, target3.id].map(&:to_s))
      expect(csv.by_col[4].sort).to eq(%w[2030 2040 2050])
    end
  end

  describe 'GET show' do
    subject { get :show, params: {id: target.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: target.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {target: valid_attributes} }

      it 'creates a new Target' do
        expect { subject }.to change(Target, :count).by(1)
      end

      it 'redirects to the created Target' do
        expect(subject).to redirect_to(admin_target_path(Target.order(:created_at).last))
      end

      it 'new target is for 2 legislations' do
        subject

        target = Target.order(:created_at).last

        expect(target.legislations.count).to eq(2)
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {target: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Target' do
        expect { subject }.not_to change(Target, :count)
      end
    end
  end

  def response_as_csv
    CSV.parse(response.body, headers: true)
  end
end
