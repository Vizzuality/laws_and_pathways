require 'rails_helper'

RSpec.describe Admin::LegislationsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let(:geography) { create(:geography) }

  let!(:legislation) { create(:legislation) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
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
          date_passed: Date.parse('2/4/2004'),
          law_id: 1001,
          visibility_status: 'pending',
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
              event_type: 'drafted',
              title: 'Event 1',
              description: 'Description 1',
              url: 'https://validurl1.com'
            },
            {
              date: 3.days.ago,
              event_type: 'approved',
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
          ['Event 1', 'drafted', 'Description 1', 'https://validurl1.com'],
          ['Event 2', 'approved', 'Description 2', 'https://validurl2.com']
        ]

        last_legislation_created.tap do |l|
          expect(l.title).to eq('Legislation POST title')
          expect(l.description).to eq('Legislation POST description')
          expect(l.visibility_status).to eq('pending')
          expect(l.law_id).to eq(1001)
          expect(l.date_passed).to eq(Date.parse('2/4/2004'))
          expect(l.geography_id).to eq(geography.id)
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

    context 'with invalid params' do
      let(:invalid_attributes) { attributes_for(:legislation).merge(title: nil) }

      subject { post :create, params: {legislation: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Litigation' do
        expect { subject }.not_to change(Legislation, :count)
      end
    end
  end

  describe 'DELETE destroy' do
    context 'with valid params' do
      let!(:legislations_to_delete) { create(:legislation) }

      let(:id_to_delete) { legislations_to_delete.id }

      subject { delete :destroy, params: {id: legislations_to_delete.id} }

      it 'soft deletes Legislation' do
        expect(legislations_to_delete.discarded_at).to be_nil

        # should disappear from default scope
        expect { subject }.to change { Legislation.count }.by(-1)
        expect(Legislation.find_by_id(id_to_delete)).to be_nil

        # .. but still be in database
        expect(legislations_to_delete.reload.discarded_at).to_not be_nil
        expect(Legislation.with_discarded.discarded.find(id_to_delete)).to_not be_nil

        expect(flash[:notice]).to match('Successfully deleted selected Legislation')
      end
    end

    context 'with invalid params' do
      subject { post :batch_action, params: {batch_action: 'destroy', collection_selection: [9876]} }

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_legislations_path)
        expect(flash[:alert]).to match('Could not delete selected Legislations')
      end
    end
  end

  describe 'Batch Actions' do
    context 'delete' do
      let!(:legislations_to_delete_1) { create(:legislation) } # TODO: rename
      let!(:legislations_to_delete_2) { create(:legislation) }
      let!(:legislations_to_delete_3) { create(:legislation) }
      let!(:legislations_to_keep_1) { create(:legislation) }
      let!(:legislations_to_keep_2) { create(:legislation) }

      let(:ids_to_delete) do
        [legislations_to_delete_1.id,
         legislations_to_delete_2.id,
         legislations_to_delete_3.id]
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

        expect(legislations_to_delete_1.reload.discarded_at).to_not be_nil
        expect(Legislation.with_discarded.discarded.find_by_id(ids_to_delete)).to_not be_nil

        expect(flash[:notice]).to match('Successfully deleted 3 Legislations')
      end
    end

    context 'archive' do
      let!(:legislation_to_archive_1) { create(:legislation, visibility_status: 'draft') }
      let!(:legislation_to_archive_2) { create(:legislation, visibility_status: 'draft') }
      let!(:legislation_to_archive_3) { create(:legislation, visibility_status: 'draft') }
      let!(:legislation_to_keep_1) { create(:legislation, visibility_status: 'draft') }
      let!(:legislation_to_keep_2) { create(:legislation, visibility_status: 'draft') }

      let(:ids_to_archive) do
        [legislation_to_archive_1.id,
         legislation_to_archive_2.id,
         legislation_to_archive_3.id]
      end

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
        expect(legislation_to_archive_3.reload.visibility_status).to eq('archived')
        expect(legislation_to_keep_1.reload.visibility_status).to eq('draft')
        expect(legislation_to_keep_2.reload.visibility_status).to eq('draft')

        expect(flash[:notice]).to match('Successfully archived 3 Legislations')
      end
    end
  end

  def last_legislation_created
    Legislation.order(:created_at).last
  end
end
