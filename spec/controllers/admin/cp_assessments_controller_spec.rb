require 'rails_helper'

RSpec.describe Admin::CPAssessmentsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let(:company) { create(:company) }
  let!(:cp_assessment) { create(:cp_assessment) }
  let(:valid_attributes) { attributes_for(:cp_assessment, company_id: company.id) }
  let(:invalid_attributes) { valid_attributes.merge(publication_date: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: cp_assessment.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: cp_assessment.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {cp_assessment: valid_attributes} }

      it 'creates a new Assessment' do
        expect { subject }.to change(CP::Assessment, :count).by(1)
      end

      it 'redirects to the created Assessment' do
        expect(subject).to redirect_to(admin_cp_assessment_path(CP::Assessment.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {cp_assessment: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Assessment' do
        expect { subject }.not_to change(CP::Assessment, :count)
      end
    end
  end
end
