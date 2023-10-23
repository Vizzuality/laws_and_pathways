require 'rails_helper'

RSpec.describe Admin::ASCORAssessmentIndicatorsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:ascor_assessment_indicator) { create(:ascor_assessment_indicator) }
  let(:valid_attributes) { attributes_for(:ascor_assessment_indicator).merge code: 'TEST' }
  let(:invalid_attributes) { valid_attributes.merge code: nil }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: ascor_assessment_indicator.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: ascor_assessment_indicator.id} }

    it { is_expected.to be_successful }
  end

  describe 'PUT update' do
    context 'with valid params' do
      subject { put :update, params: {id: ascor_assessment_indicator.id, ascor_assessment_indicator: valid_attributes} }

      it 'updates the requested ASCOR Assessment Indicator' do
        expect { subject }.to change { ascor_assessment_indicator.reload.code }.to(valid_attributes[:code])
      end

      it 'redirects to the ASCOR Assessment Indicator' do
        expect(subject).to redirect_to(admin_ascor_assessment_indicator_path(ascor_assessment_indicator))
      end
    end

    context 'with invalid params' do
      subject { put :update, params: {id: ascor_assessment_indicator.id, ascor_assessment_indicator: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes does not update the ASCOR Assessment Indicator' do
        expect { subject }.not_to change(ascor_assessment_indicator.reload, :code)
      end
    end
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: {id: ascor_assessment_indicator.id} }

    it 'destroys the requested ASCOR Assessment Indicator' do
      expect { subject }.to change(ASCOR::AssessmentIndicator, :count).by(-1)
    end

    it 'redirects to the ASCOR Assessment Indicators list' do
      expect(subject).to redirect_to(admin_ascor_assessment_indicators_path)
    end
  end
end
