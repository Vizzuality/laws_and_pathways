require 'rails_helper'

RSpec.describe Admin::LitigationsController, type: :controller do
  before(:each) { sign_in admin }

  let(:admin) { create(:admin_user) }
  let!(:litigation) { create(:litigation, :with_sides) }
  let(:side_geography) { create(:geography) }
  let(:side_company) { create(:company) }
  let(:geography) { create(:geography) }
  let(:sector) { create(:laws_sector) }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: litigation.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: litigation.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_attributes) {
        attributes_for(
          :litigation,
          title: 'Litigation POST title',
          summary: 'Litigation POST summary',
          at_issue: 'At issue',
          geography_id: geography.id,
          jurisdiction: 'Court in Country',
          laws_sector_ids: [sector.id],
          created_by_id: admin.id,
          updated_by_id: admin.id,
          visibility_status: 'pending',
          litigation_sides_attributes: [
            attributes_for(:litigation_side),
            attributes_for(
              :litigation_side,
              :company,
              connected_with: "Company-#{side_company.id}"
            ),
            attributes_for(
              :litigation_side,
              :geography,
              connected_with: "Geography-#{side_geography.id}"
            )
          ],
          documents_attributes: [
            attributes_for(:document, name: 'doc 1'),
            attributes_for(:document_uploaded, name: 'doc 2')
          ],
          events_attributes: [
            {
              date: 5.days.ago,
              event_type: 'case_started',
              title: 'Event 1',
              description: 'Description 1',
              url: 'https://validurl1.com'
            },
            {
              date: 3.days.ago,
              event_type: 'case_dismissed',
              title: 'Event 2',
              description: 'Description 2',
              url: 'https://validurl2.com'
            }
          ]
        )
      }

      subject { post :create, params: {litigation: valid_attributes} }

      it 'creates a new Litigation' do
        expect { subject }.to change(Litigation, :count).by(1)

        expected_documents_attrs = [
          ['doc 1', 'en', 'https://test.com'], ['doc 2', 'en', '']
        ]
        expected_events_attrs = [
          ['Event 1', 'case_started', 'Description 1', 'https://validurl1.com'],
          ['Event 2', 'case_dismissed', 'Description 2', 'https://validurl2.com']
        ]

        last_litigation_created.tap do |l|
          expect(l.title).to eq('Litigation POST title')
          expect(l.summary).to eq('Litigation POST summary')
          expect(l.at_issue).to eq('At issue')
          expect(l.visibility_status).to eq('pending')
          expect(l.laws_sectors.first.id).to eq(sector.id)
          expect(l.geography_id).to eq(geography.id)
          expect(l.jurisdiction).to eq('Court in Country')
          expect(l.litigation_sides.pluck(:party_type)).to eq(%w[individual corporation government])
          expect(
            l.documents.pluck(:name, :language, :external_url).sort
          ).to eq(expected_documents_attrs)
          expect(
            l.events.order(:date).pluck(:title, :event_type, :description, :url)
          ).to eq(expected_events_attrs)
        end
      end

      it 'redirects to the created Litigation' do
        expect(subject).to redirect_to(admin_litigation_path(last_litigation_created))
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { attributes_for(:litigation).merge(title: nil) }

      subject { post :create, params: {litigation: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Litigation' do
        expect { subject }.not_to change(Litigation, :count)
      end
    end
  end

  describe 'PATCH update' do
    let!(:litigation_to_update) { create(:litigation, :draft, :with_sides) }

    context 'with valid params' do
      let(:valid_update_params) { {title: 'title was updated', visibility_status: 'published'} }

      subject { patch :update, params: {id: litigation_to_update.id, litigation: valid_update_params} }

      it 'does not create another record' do
        expect { subject }.not_to change(Litigation, :count)
      end

      it 'updates existing Litigation' do
        expect { subject }.to change { litigation_to_update.reload.title }.to('title was updated')
          .and change { litigation_to_update.visibility_status }.to('published')
      end

      it 'creates "edited" activity when editing' do
        patch :update, params: {id: litigation_to_update.id, litigation: valid_update_params.delete(:visibility_status)}

        activity = PublicActivity::Activity.last

        expect(activity.owner).to eq(admin)
        expect(activity.trackable_id).to eq(litigation_to_update.id)
        expect(activity.key).to eq('litigation.edited')
      end

      it 'creates "published" activity when publishing' do
        expect { subject }.to change(PublicActivity::Activity, :count).by(1)

        activity = PublicActivity::Activity.last

        expect(activity.owner).to eq(admin)
        expect(activity.trackable_id).to eq(litigation_to_update.id)
        expect(activity.key).to eq('litigation.published')
      end

      it 'redirects to the updated Litigation' do
        expect(subject).to redirect_to(admin_litigation_path(litigation_to_update))
      end

      context 'as editor' do
        let(:editor) { create(:admin_user, :editor_laws) }

        before(:each) { sign_in editor }

        it 'cannot publish' do
          expect { subject }.not_to change(litigation_to_update, :visibility_status)
        end

        it 'cannot unpublish' do
          published_litigation = create(:litigation, :published)
          expect {
            patch :update, params: {id: published_litigation.id, litigation: {visibility_status: 'draft'}}
          }.not_to change(published_litigation, :visibility_status)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:litigation) { create(:litigation, discarded_at: nil) }
    subject { delete :destroy, params: {id: litigation.id} }

    context 'with valid params' do
      let!(:litigation_side) { create(:litigation_side, litigation: litigation) }
      let!(:event) { create(:litigation_event, eventable: litigation) }
      let!(:document) { create(:document, documentable: litigation) }

      let!(:legislation) { create(:legislation, litigations: [litigation]) }
      let!(:external_legislation) do
        create(:external_legislation, litigations: [litigation])
      end

      before do
        expect { subject }.to change { Litigation.count }.by(-1)
      end

      it 'discards litigation object' do
        expect(Litigation.find_by_id(litigation.id)).to be_nil
      end

      it 'set discarded_at date to litigation object' do
        expect(litigation.reload.discarded_at).to_not be_nil
      end

      it 'shows discarded litigations in all_discarded scope' do
        expect(Litigation.all_discarded.find(litigation.id)).to_not be_nil
      end

      it 'discard all litigation sides' do
        expect(LitigationSide.find_by_id(litigation_side.id)).to be_nil
      end

      it 'discard all events' do
        expect(Event.find_by_id(event.id)).to be_nil
      end

      it 'discard all documents' do
        expect(Document.find_by_id(document.id)).to be_nil
      end

      it 'removes discarded litigation from legislation' do
        expect(legislation.reload.litigations).to be_empty
      end

      it 'removes discarded litigation from external_legislations' do
        expect(external_legislation.reload.litigations).to be_empty
      end

      it 'shows proper notice' do
        expect(flash[:notice]).to match('Successfully deleted selected Litigation')
      end
    end

    context 'with invalid params' do
      let(:command) { double }

      before do
        expect(::Command::Destroy::Litigation).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_litigations_path)
        expect(flash[:alert]).to match('Could not delete selected Litigation')
      end
    end

    context 'when geography does not exist' do
      before do
        litigation.geography.litigations = []
      end

      it 'soft-delete even if geography is nil' do
        expect { subject }.to change { Litigation.count }.by(-1)
      end
    end
  end

  describe 'Batch Actions' do
    context 'delete' do
      let!(:litigation_to_delete_1) { create(:litigation) }
      let!(:litigation_to_delete_2) { create(:litigation) }
      let!(:litigation_to_delete_3) { create(:litigation) }
      let!(:litigation_to_keep_1) { create(:litigation) }
      let!(:litigation_to_keep_2) { create(:litigation) }

      let(:ids_to_delete) do
        [litigation_to_delete_1.id,
         litigation_to_delete_2.id,
         litigation_to_delete_3.id]
      end

      subject do
        post :batch_action,
             params: {
               batch_action: 'destroy',
               collection_selection: ids_to_delete
             }
      end

      it 'soft deletes Litigations collection' do
        expect { subject }.to change { Litigation.count }.by(-3)
        expect(Litigation.find_by_id(ids_to_delete)).to be_nil

        expect(litigation_to_delete_1.reload.discarded_at).to_not be_nil
        expect(Litigation.all_discarded.find_by_id(ids_to_delete)).to_not be_nil

        expect(flash[:notice]).to match('Successfully deleted 3 Litigations')
      end
    end

    context 'archive' do
      let!(:litigation_to_archive_1) { create(:litigation, visibility_status: 'draft') }
      let!(:litigation_to_archive_2) { create(:litigation, visibility_status: 'draft') }
      let!(:litigation_to_keep_1) { create(:litigation, visibility_status: 'draft') }
      let!(:litigation_to_keep_2) { create(:litigation, visibility_status: 'draft') }

      let(:ids_to_archive) { [litigation_to_archive_1.id, litigation_to_archive_2.id] }

      subject do
        post :batch_action,
             params: {
               batch_action: 'archive',
               collection_selection: ids_to_archive
             }
      end

      it 'archives Litigations collection' do
        subject

        expect(litigation_to_archive_1.reload.visibility_status).to eq('archived')
        expect(litigation_to_archive_2.reload.visibility_status).to eq('archived')
        expect(litigation_to_keep_1.reload.visibility_status).to eq('draft')
        expect(litigation_to_keep_2.reload.visibility_status).to eq('draft')

        expect(flash[:notice]).to match('Successfully archived 2 Litigations')
      end
    end

    context 'publish' do
      let!(:litigation_to_publish_1) { create(:litigation, visibility_status: 'draft') }
      let!(:litigation_to_publish_2) { create(:litigation, visibility_status: 'draft') }
      let!(:litigation_to_keep_1) { create(:litigation, visibility_status: 'draft') }
      let!(:litigation_to_keep_2) { create(:litigation, visibility_status: 'draft') }

      let(:ids_to_publish) { [litigation_to_publish_1.id, litigation_to_publish_2.id] }

      subject do
        post :batch_action,
             params: {
               batch_action: 'publish',
               collection_selection: ids_to_publish
             }
      end

      it 'publishes Litigations collection' do
        subject

        expect(litigation_to_publish_1.reload.visibility_status).to eq('published')
        expect(litigation_to_publish_2.reload.visibility_status).to eq('published')
        expect(litigation_to_keep_1.reload.visibility_status).to eq('draft')
        expect(litigation_to_keep_2.reload.visibility_status).to eq('draft')

        expect(flash[:notice]).to match('Successfully published 2 Litigations')
      end
    end
  end

  def last_litigation_created
    Litigation.order(:created_at).last
  end
end
