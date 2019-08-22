require 'rails_helper'

RSpec.describe Admin::LitigationsController, type: :controller do
  before(:each) { sign_in admin }

  let(:admin) { create(:admin_user) }
  let!(:litigation) { create(:litigation, :with_sides) }
  let(:side_geography) { create(:geography) }
  let(:side_company) { create(:company) }
  let(:geography) { create(:geography) }

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
          core_objective: 'objective',
          geography_id: geography.id,
          jurisdiction_id: geography.id,
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

        last_litigation_created.tap do |l|
          expect(l.title).to eq('Litigation POST title')
          expect(l.summary).to eq('Litigation POST summary')
          expect(l.core_objective).to eq('objective')
          expect(l.visibility_status).to eq('pending')
          expect(l.geography_id).to eq(geography.id)
          expect(l.jurisdiction_id).to eq(geography.id)
          expect(l.litigation_sides.pluck(:party_type)).to eq(%w[individual corporation government])
          expect(l.documents.pluck(:name, :language, :external_url).sort)
            .to eq([['doc 1', 'en', 'https://test.com'], ['doc 2', 'en', '']])
          expect(l.events.order(:date).pluck(:title, :event_type, :description, :url))
            .to eq([
                     ['Event 1', 'case_started', 'Description 1', 'https://validurl1.com'],
                     ['Event 2', 'case_dismissed', 'Description 2', 'https://validurl2.com']
                   ])
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

  def last_litigation_created
    Litigation.order(:created_at).last
  end
end
