require 'rails_helper'

RSpec.describe Admin::GeographiesController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:geography) { create(:geography) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: geography.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: geography.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_params) do
        attributes_for(
          :geography,
          iso: 'ABC',
          name: 'Test Country',
          region: Geography::REGIONS.last,
          visibility_status: 'pending',
          indc_url: 'https://example.indc.pl',
          federal: true,
          federal_details: 'federal details text',
          legislative_process: 'legislative process text',
          events_attributes: [
            {
              date: 5.months.ago,
              event_type: 'election',
              title: 'president elections',
              description: 'Description of elections'
            }
          ]
        )
      end

      subject { post :create, params: {geography: valid_params} }

      it 'creates a new Geography' do
        expect { subject }.to change(Geography, :count).by(1)

        last_geography_created.tap do |g|
          expect(g.iso).to eq(valid_params[:iso])
          expect(g.name).to eq(valid_params[:name])
          expect(g.region).to eq(valid_params[:region])
          expect(g.visibility_status).to eq(valid_params[:visibility_status])
          expect(g.indc_url).to eq(valid_params[:indc_url])
          expect(g.federal).to eq(valid_params[:federal])
          expect(g.federal_details).to eq(valid_params[:federal_details])
          expect(g.legislative_process).to eq(valid_params[:legislative_process])
          expect(g.events.pluck(:title, :event_type, :description))
            .to eq(valid_params[:events_attributes].pluck(:title, :event_type, :description))
        end
      end

      it 'redirects to the created Geography' do
        expect(subject).to redirect_to(admin_geography_path(Geography.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { attributes_for(:geography, iso: nil) }

      subject { post :create, params: {geography: invalid_params} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Geography' do
        expect { subject }.not_to change(Geography, :count)
      end
    end
  end

  def last_geography_created
    Geography.order(:created_at).last
  end
end
