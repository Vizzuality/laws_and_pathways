require 'rails_helper'

RSpec.describe Admin::CPAssessmentsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:company) { create(:company) }
  let_it_be(:bank) { create(:bank) }
  let_it_be(:company_cp_assessment) { create(:cp_assessment, cp_assessmentable: company) }
  let_it_be(:bank_cp_assessment) { create(:cp_assessment, cp_assessmentable: bank) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    context 'when the assessment is for a company' do
      subject { get :show, params: {id: company_cp_assessment.id} }

      it { is_expected.to be_successful }
    end

    context 'when the assessment is for a bank' do
      subject { get :show, params: {id: bank_cp_assessment.id} }

      it { is_expected.to be_successful }
    end
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: company_cp_assessment.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      context 'when the assessment is for a company' do
        subject { post :create, params: {cp_assessment: valid_attributes} }

        let(:valid_attributes) { attributes_for(:cp_assessment, cp_assessmentable_id: "Company::#{company.id}") }

        it 'creates a new Assessment' do
          expect { subject }.to change(CP::Assessment, :count).by(1)
        end

        it 'redirects to the created Assessment' do
          expect(subject).to redirect_to(admin_cp_assessment_path(CP::Assessment.order(:created_at).last))
        end
      end

      context 'when the assessment is for a bank' do
        subject { post :create, params: {cp_assessment: valid_attributes} }

        let(:valid_attributes) { attributes_for(:cp_assessment, cp_assessmentable_id: "Bank::#{bank.id}") }

        it 'creates a new Assessment' do
          expect { subject }.to change(CP::Assessment, :count).by(1)
        end

        it 'redirects to the created Assessment' do
          expect(subject).to redirect_to(admin_cp_assessment_path(CP::Assessment.order(:created_at).last))
        end
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {cp_assessment: invalid_attributes} }

      let(:invalid_attributes) { attributes_for(:cp_assessment).merge(publication_date: nil) }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Assessment' do
        expect { subject }.not_to change(CP::Assessment, :count)
      end
    end
  end
end
