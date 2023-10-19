require 'rails_helper'

RSpec.describe Admin::ASCORAssessmentsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:ascor_country) { create :ascor_country, name: 'TEST', iso: 'TEST' }
  let_it_be(:ascor_assessment_result) { create(:ascor_assessment_result) }
  let_it_be(:ascor_assessment) { ascor_assessment_result.assessment }
  let(:valid_attributes) do
    attributes_for(:ascor_assessment).merge(
      country_id: ascor_country.id,
      results_attributes: {
        '0' => attributes_for(:ascor_assessment_result).merge(
          indicator_id: ascor_assessment_result.indicator_id
        )
      }
    )
  end
  let(:invalid_attributes) { valid_attributes.merge country_id: nil }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: ascor_assessment.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: ascor_assessment.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {ascor_assessment: valid_attributes} }

      it 'creates a new ASCOR Assessment' do
        expect { subject }.to change(ASCOR::Assessment, :count).by(1)
      end

      it 'redirects to the created Assessment' do
        expect(subject).to redirect_to(admin_ascor_assessment_path(ASCOR::Assessment.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {ascor_assessment: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes does not create a ASCOR Assessment' do
        expect { subject }.not_to change(ASCOR::Assessment, :count)
      end
    end
  end

  describe 'PUT update' do
    context 'with valid params' do
      subject { put :update, params: {id: ascor_assessment.id, ascor_assessment: valid_attributes} }

      before do
        valid_attributes[:results_attributes]['0'][:id] = ascor_assessment_result.id
      end

      it 'updates the requested assessment' do
        expect { subject }.to change { ascor_assessment.reload.country_id }.to(ascor_country.id)
      end

      it 'redirects to the assessment' do
        expect(subject).to redirect_to(admin_ascor_assessment_path(ascor_assessment))
      end
    end

    context 'with invalid params' do
      subject { put :update, params: {id: ascor_assessment.id, ascor_assessment: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes does not update the requested benchmark' do
        expect { subject }.not_to(change { ascor_assessment.reload.country_id })
      end
    end
  end
end
