require 'rails_helper'

RSpec.describe Admin::ExternalLegislationsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let(:geography) { create(:geography) }

  let_it_be(:external_legislation) { create(:external_legislation) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: external_legislation.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: external_legislation.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_attributes) {
        attributes_for(:external_legislation).merge(
          name: 'External Legislation POST title',
          url: 'https://www.external-legislation/doc',
          geography_id: geography.id
        )
      }

      subject { post :create, params: {external_legislation: valid_attributes} }

      it 'creates a new ExternalLegislation' do
        expect { subject }.to change(ExternalLegislation, :count).by(1)

        last_legislation_created.tap do |l|
          expect(l.name).to eq('External Legislation POST title')
          expect(l.url).to eq('https://www.external-legislation/doc')
          expect(l.geography_id).to eq(geography.id)
        end
      end

      it 'redirects to the created ExternalLegislation' do
        expect(subject).to redirect_to(admin_external_legislation_path(last_legislation_created))
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { attributes_for(:external_legislation).merge(name: nil) }

      subject { post :create, params: {legislation: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a ExternalLegislation' do
        expect { subject }.not_to change(ExternalLegislation, :count)
      end
    end
  end

  def last_legislation_created
    ExternalLegislation.order(:created_at).last
  end
end
