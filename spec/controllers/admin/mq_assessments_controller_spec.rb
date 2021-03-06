require 'rails_helper'

RSpec.describe Admin::MQAssessmentsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:company) { create(:company) }
  let_it_be(:mq_assessment) { create(:mq_assessment, company: company) }

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

  describe 'PATCH update' do
    let!(:assessment_to_update) do
      create(:mq_assessment,
             company: company,
             assessment_date: '2012-01-01',
             publication_date: '2012-03-03',
             level: '2',
             notes: 'Old notes',
             questions: [
               {level: '0', question: 'Question 1', answer: 'Yes'},
               {level: '1', question: 'Question 2', answer: 'No'},
               {level: '1', question: 'Question 3', answer: 'No'},
               {level: '2', question: 'Question 4', answer: 'Yes'}
             ])
    end

    context 'with valid params' do
      let(:valid_update_params) do
        {
          assessment_date: '2019-01-01',
          publication_date: '2019-03-03',
          level: '3',
          notes: 'Some new notes',
          questions_attributes: [
            {answer: 'Yes'},
            {answer: 'Not applicable'},
            {answer: 'Yes'},
            {answer: 'No'}
          ]
        }
      end

      subject { patch :update, params: {id: assessment_to_update.id, mq_assessment: valid_update_params} }

      it 'does not create another record' do
        expect { subject }.not_to change(MQ::Assessment, :count)
      end

      it 'updates existing Assessment' do
        subject

        assessment_to_update.reload

        expect(assessment_to_update.level).to eq('3')
        expect(assessment_to_update.assessment_date).to eq(Date.parse('2019-01-01'))
        expect(assessment_to_update.publication_date).to eq(Date.parse('2019-03-03'))
        expect(assessment_to_update.notes).to eq('Some new notes')
        expect(assessment_to_update.read_attribute(:questions)).to contain_exactly(
          {level: '0', question: 'Question 1', answer: 'Yes'}.with_indifferent_access,
          {level: '1', question: 'Question 2', answer: 'Not applicable'}.with_indifferent_access,
          {level: '1', question: 'Question 3', answer: 'Yes'}.with_indifferent_access,
          {level: '2', question: 'Question 4', answer: 'No'}.with_indifferent_access
        )
      end

      it 'redirects to the updated Assessment' do
        expect(subject).to redirect_to(admin_mq_assessment_path(assessment_to_update))
      end
    end
  end
end
