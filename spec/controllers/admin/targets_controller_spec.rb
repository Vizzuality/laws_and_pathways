require 'rails_helper'

RSpec.describe Admin::TargetsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:target) { create(:target) }
  let(:sector) { create(:sector) }
  let(:location) { create(:location) }
  let(:legislations) { create_list(:legislation, 2) }
  let(:valid_attributes) {
    attributes_for(
      :target,
      legislation_ids: legislations.pluck(:id),
      location_id: location.id,
      sector_id: sector.id
    )
  }
  let(:invalid_attributes) { valid_attributes.merge(type: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
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

        expect(target.legislations.count).to be(2)
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
end
