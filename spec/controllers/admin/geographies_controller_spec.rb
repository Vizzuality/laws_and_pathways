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
          federal: true,
          federal_details: 'federal details text',
          legislative_process: 'legislative process text',
          geography_type: 'supranational',
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
          expect(g.federal).to eq(valid_params[:federal])
          expect(g.federal_details).to eq(valid_params[:federal_details])
          expect(g.legislative_process).to eq(valid_params[:legislative_process])
          expect(g.geography_type).to eq(valid_params[:geography_type])
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

  describe 'PATCH update' do
    let!(:geography_to_update) { create(:geography) }

    context 'with valid params' do
      let(:valid_update_params) { {name: 'name was updated'} }

      subject { patch :update, params: {id: geography_to_update.id, geography: valid_update_params} }

      it 'does not create another record' do
        expect { subject }.not_to change(Geography, :count)
      end

      it 'updates existing Geography' do
        expect { subject }.to change { geography_to_update.reload.name }.to('name was updated')
      end

      it 'creates "edited" activity' do
        expect { subject }.to change(PublicActivity::Activity, :count).by(1)

        expect(PublicActivity::Activity.last.trackable_id).to eq(geography_to_update.id)
        expect(PublicActivity::Activity.last.key).to eq('geography.edited')
      end

      it 'redirects to the updated Geography' do
        expect(subject).to redirect_to(admin_geography_path(geography_to_update))
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:geography) { create(:geography, discarded_at: nil) }

    context 'with valid params' do
      let!(:legislation) { create(:legislation, geography: geography) }
      let!(:litigation) { create(:litigation, geography: geography) }
      let!(:event) { create(:geography_event, eventable: geography) }

      subject { delete :destroy, params: {id: geography.id} }

      before do
        expect { subject }.to change { Geography.count }.by(-1)
      end

      it 'discards geography object' do
        expect(Geography.find_by_id(geography.id)).to be_nil
      end

      it 'set discarded_at date to geography object' do
        expect(geography.reload.discarded_at).to_not be_nil
      end

      it 'discard all events' do
        expect(Event.find_by_id(event.id)).to be_nil
      end

      it 'shows discarded geography in all_discarded scope' do
        expect(Geography.all_discarded.find(geography.id)).to_not be_nil
      end

      it 'removes discarded geography from legislation' do
        expect(legislation.reload.geography).to be_nil
      end

      it 'removes discarded geography from litigation' do
        expect(litigation.reload.geography).to be_nil
      end

      it 'shows proper notice' do
        expect(flash[:notice]).to match('Successfully deleted selected Geography')
      end
    end

    context 'with invalid params' do
      let(:command) { double }

      subject { delete :destroy, params: {id: geography.id} }

      before do
        expect(::Command::Destroy::Geography).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_geographies_path)
        expect(flash[:alert]).to match('Could not delete selected Geography')
      end
    end
  end

  def last_geography_created
    Geography.order(:created_at).last
  end
end
