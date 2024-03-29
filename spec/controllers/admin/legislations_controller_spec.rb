require 'rails_helper'

RSpec.describe Admin::LegislationsController, type: :controller, factory_default: :keep do
  let(:admin) { create(:admin_user) }
  let_it_be(:geography) { create_default(:geography) }
  let_it_be(:sector) { create(:laws_sector) }

  let_it_be(:legislation) { create(:legislation, visibility_status: 'published') }
  let_it_be(:legislation_archived) { create(:legislation, visibility_status: 'archived') }
  let_it_be(:legislation_discarded) { create(:legislation, discarded_at: 10.days.ago) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET index (with .json format)' do
    it 'returns only none discarded and none archived records' do
      get :index, format: 'json'

      expect(
        JSON.parse(response.body).map { |l| [l['id'], l['visibility_status']] }
      ).to eq([[legislation.id, 'published']])
    end
  end

  describe 'GET index with .csv format' do
    before :each do
      get :index, format: 'csv'
    end

    it('returns CSV file') do
      expect(response.header['Content-Type']).to include('text/csv')
    end
  end

  describe 'GET show' do
    subject { get :show, params: {id: legislation.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: legislation.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_attributes) {
        attributes_for(:legislation).merge(
          title: 'Legislation POST title',
          description: 'Legislation POST description',
          law_id: 1001,
          visibility_status: 'pending',
          legislation_type: 'legislative',
          laws_sector_ids: [sector.id],
          geography_id: geography.id,
          documents_attributes: [
            attributes_for(:document).merge(
              name: 'doc 1', language: 'en', external_url: 'http://test.com/file.pdf'
            ),
            attributes_for(:document_uploaded).merge(
              name: 'doc 2', language: 'pl'
            )
          ],
          events_attributes: [
            {
              date: 5.days.ago,
              event_type: 'amended',
              title: 'Event 1',
              description: 'Description 1',
              url: 'https://validurl1.com'
            },
            {
              date: 3.days.ago,
              event_type: 'passed/approved',
              title: 'Event 2',
              description: 'Description 2',
              url: 'https://validurl2.com'
            }
          ]
        )
      }

      subject { post :create, params: {legislation: valid_attributes} }

      it 'creates a new Legislation' do
        expect { subject }.to change(Legislation, :count).by(1)

        expected_events_attrs = [
          ['Event 1', 'amended', 'Description 1', 'https://validurl1.com'],
          ['Event 2', 'passed/approved', 'Description 2', 'https://validurl2.com']
        ]

        last_legislation_created.tap do |l|
          expect(l.title).to eq('Legislation POST title')
          expect(l.description).to eq('Legislation POST description')
          expect(l.visibility_status).to eq('pending')
          expect(l.law_id).to eq(1001)
          expect(l.geography_id).to eq(geography.id)
          expect(l.laws_sectors.first.id).to eq(sector.id)
          expect(l.legislative?).to be(true)
          expect(l.documents.pluck(:name, :language, :external_url).sort)
            .to eq([['doc 1', 'en', 'http://test.com/file.pdf'], ['doc 2', 'pl', '']])
          expect(
            l.events.order(:date).pluck(:title, :event_type, :description, :url)
          ).to eq(expected_events_attrs)
        end
      end

      it 'redirects to the created Legislation' do
        expect(subject).to redirect_to(admin_legislation_path(last_legislation_created))
      end
    end

    context 'with valid params setting parent_legislation' do
      let!(:parent_legislation) { create(:legislation, visibility_status: 'published') }

      let(:valid_attributes_with_parent) {
        attributes_for(:legislation).merge(
          title: 'Legislation POST title 22',
          description: 'Legislation POST description 22',
          law_id: 1003,
          visibility_status: 'pending',
          legislation_type: 'legislative',
          geography_id: geography.id,
          parent_id: parent_legislation.id
        )
      }

      subject { post :create, params: {legislation: valid_attributes_with_parent} }

      it 'creates a new Legislation' do
        expect { subject }.to change(Legislation, :count).by(1)

        last_legislation_created.tap do |l|
          expect(l.title).to eq('Legislation POST title 22')
          expect(l.description).to eq('Legislation POST description 22')
          expect(l.visibility_status).to eq('pending')
          expect(l.law_id).to eq(1003)
          expect(l.parent_id).to eq(parent_legislation.id)
          expect(l.legislative?).to be(true)
        end
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { attributes_for(:legislation).merge(title: nil) }

      subject { post :create, params: {legislation: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Litigation' do
        expect { subject }.not_to change(Legislation, :count)
      end
    end
  end

  describe 'PATCH update' do
    let!(:legislation_to_update) { create(:legislation, visibility_status: 'published') }

    context 'with valid params' do
      let(:valid_update_params) { {title: 'title was updated'} }

      subject { patch :update, params: {id: legislation_to_update.id, legislation: valid_update_params} }

      it 'does not create another record' do
        expect { subject }.not_to change(Legislation, :count)
      end

      it 'updates existing Legislation' do
        expect { subject }.to change { legislation_to_update.reload.title }.to('title was updated')
      end

      it 'creates "edited" activity' do
        expect { subject }.to change(PublicActivity::Activity, :count).by(1)

        expect(PublicActivity::Activity.last.trackable_id).to eq(legislation_to_update.id)
        expect(PublicActivity::Activity.last.key).to eq('legislation.edited')
      end

      it 'redirects to the updated Legislation' do
        expect(subject).to redirect_to(admin_legislation_path(legislation_to_update))
      end
    end
  end

  describe 'DELETE destroy' do
    render_views false

    let!(:legislation_to_delete) { create(:legislation, discarded_at: nil) }

    context 'with valid params' do
      let!(:document) { create(:document, documentable: legislation_to_delete) }
      let!(:event) { create(:legislation_event, eventable: legislation_to_delete) }

      let(:id_to_delete) { legislation_to_delete.id }

      subject { delete :destroy, params: {id: legislation_to_delete.id} }

      it 'discards (soft-deletes) Legislation' do
        # should disappear from default scope
        expect { subject }.to change { Legislation.count }.by(-1)
        expect(Legislation.find_by_id(id_to_delete)).to be_nil
        expect(Event.find_by_id(event.id)).to be_nil
        expect(Document.find_by_id(document.id)).to be_nil

        # .. but still be in database
        expect(legislation_to_delete.reload.discarded_at).to_not be_nil
        expect(Legislation.all_discarded.find(id_to_delete)).to_not be_nil
        expect(Event.all_discarded.find(event.id)).to_not be_nil
        expect(Document.all_discarded.find(document.id)).to_not be_nil

        expect(flash[:notice]).to match('Successfully deleted selected Legislation')
      end
    end

    context 'with invalid params' do
      subject { post :batch_action, params: {batch_action: 'destroy', collection_selection: [9876]} }

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_legislations_path)
        expect(flash[:alert]).to match('Could not delete selected Laws')
      end
    end

    context 'when geography does not exist' do
      subject { delete :destroy, params: {id: legislation_to_delete.id} }

      before do
        legislation_to_delete.geography.legislations = []
      end

      it 'soft-delete even if geography is nil' do
        expect { subject }.to change { Legislation.count }.by(-1)
      end
    end
  end

  describe 'Batch Actions' do
    context 'delete' do
      let!(:legislation_to_delete_1) { create(:legislation) }
      let!(:legislation_to_delete_2) { create(:legislation) }
      let!(:legislation_to_delete_3) { create(:legislation) }
      let!(:legislation_to_keep_1) { create(:legislation) }
      let!(:legislation_to_keep_2) { create(:legislation) }

      let(:ids_to_delete) do
        [legislation_to_delete_1.id,
         legislation_to_delete_2.id,
         legislation_to_delete_3.id]
      end

      subject do
        post :batch_action,
             params: {
               batch_action: 'destroy',
               collection_selection: ids_to_delete
             }
      end

      it 'soft deletes Legislations collection' do
        expect { subject }.to change { Legislation.count }.by(-3)
        expect(Legislation.find_by_id(ids_to_delete)).to be_nil

        expect(legislation_to_delete_1.reload.discarded_at).to_not be_nil
        expect(Legislation.all_discarded.find_by_id(ids_to_delete)).to_not be_nil

        expect(flash[:notice]).to match('Successfully deleted 3 Laws')
      end
    end

    context 'archive' do
      let!(:legislation_to_archive_1) { create(:legislation, visibility_status: 'draft') }
      let!(:legislation_to_archive_2) { create(:legislation, visibility_status: 'draft') }
      let!(:legislation_to_keep_1) { create(:legislation, visibility_status: 'draft') }
      let!(:legislation_to_keep_2) { create(:legislation, visibility_status: 'draft') }

      let(:ids_to_archive) { [legislation_to_archive_1.id, legislation_to_archive_2.id] }

      subject do
        post :batch_action,
             params: {
               batch_action: 'archive',
               collection_selection: ids_to_archive
             }
      end

      it 'archives Legislations collection' do
        subject

        expect(legislation_to_archive_1.reload.visibility_status).to eq('archived')
        expect(legislation_to_archive_2.reload.visibility_status).to eq('archived')
        expect(legislation_to_keep_1.reload.visibility_status).to eq('draft')
        expect(legislation_to_keep_2.reload.visibility_status).to eq('draft')

        expect(flash[:notice]).to match('Successfully archived 2 Laws')
      end
    end

    context 'publish' do
      let!(:legislation_to_publish_1) { create(:legislation, visibility_status: 'draft') }
      let!(:legislation_to_publish_2) { create(:legislation, visibility_status: 'draft') }
      let!(:legislation_to_keep_1) { create(:legislation, visibility_status: 'draft') }
      let!(:legislation_to_keep_2) { create(:legislation, visibility_status: 'draft') }

      let(:ids_to_publish) { [legislation_to_publish_1.id, legislation_to_publish_2.id] }

      subject do
        post :batch_action,
             params: {
               batch_action: 'publish',
               collection_selection: ids_to_publish
             }
      end

      it 'publishes Legislations collection' do
        subject

        expect(legislation_to_publish_1.reload.visibility_status).to eq('published')
        expect(legislation_to_publish_2.reload.visibility_status).to eq('published')
        expect(legislation_to_keep_1.reload.visibility_status).to eq('draft')
        expect(legislation_to_keep_2.reload.visibility_status).to eq('draft')

        expect(flash[:notice]).to match('Successfully published 2 Laws')
      end
    end
  end

  def last_legislation_created
    Legislation.order(:created_at).last
  end
end
