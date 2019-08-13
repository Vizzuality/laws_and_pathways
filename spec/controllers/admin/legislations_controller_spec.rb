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
          ]
        )
      }
      subject { post :create, params: {legislation: valid_attributes} }

      it 'creates a new Legislation' do
        expect { subject }.to change(Legislation, :count).by(1)

        last_legislation_created.tap do |l|
          expect(l.title).to eq('Legislation POST title')
          expect(l.description).to eq('Legislation POST description')
          expect(l.visibility_status).to eq('pending')
          expect(l.law_id).to eq(1001)
          expect(l.date_passed).to eq(Date.parse('2/4/2004'))
          expect(l.geography_id).to eq(geography.id)
          expect(l.documents.pluck(:name, :language, :external_url).sort)
            .to eq([['doc 1', 'en', 'http://test.com/file.pdf'], ['doc 2', 'pl', '']])
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

  def last_legislation_created
    Legislation.order(:created_at).last
  end
end
