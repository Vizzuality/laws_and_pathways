require 'rails_helper'

RSpec.describe Admin::MQAssessmentsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let(:company) { create(:company) }
  let!(:mq_assessment) { create(:mq_assessment) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: mq_assessment.id} }

    it { is_expected.to be_successful }
  end

  xdescribe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: mq_assessment.id} }

    it { is_expected.to be_successful }
  end

  xdescribe 'POST create' do
    context 'with valid params' do
      let(:valid_attributes) { attributes_for(:mq_assessment, company_id: company.id) }

      subject { post :create, params: {mq_assessment: valid_attributes} }

      it 'creates a new Assessment' do
        expect { subject }.to change(MQ::Assessment, :count).by(1)

        last_created = MQ::Assessment.order(:created_at).last

        # for now update everything except questions
        expect(last_created).to have_attributes(valid_attributes.except(:questions))
      end

      it 'redirects to the created Assessment' do
        expect(subject).to redirect_to(admin_mq_assessment_path(MQ::Assessment.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { attributes_for(:mq_assessment, company_id: company.id, publication_date: nil) }

      subject { post :create, params: {mq_assessment: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Assessment' do
        expect { subject }.not_to change(MQ::Assessment, :count)
      end
    end
  end
end
