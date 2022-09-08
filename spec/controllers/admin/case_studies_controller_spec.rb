require 'rails_helper'

RSpec.describe Admin::CaseStudiesController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:case_study) { create(:case_study) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: case_study.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: case_study.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_params) do
        attributes_for(
          :case_study,
          organization: 'My amazing company',
          link: 'https://example.com',
          text: 'Test text'
        )
      end

      subject { post :create, params: {case_study: valid_params} }

      it 'creates a new CaseStudy' do
        expect { subject }.to change(CaseStudy, :count).by(1)

        last_case_study_created.tap do |g|
          expect(g.organization).to eq(valid_params[:organization])
          expect(g.text).to eq(valid_params[:text])
          expect(g.link).to eq(valid_params[:link])
        end
      end

      it 'redirects to the created CaseStudy' do
        expect(subject).to redirect_to(admin_case_study_path(CaseStudy.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { attributes_for(:case_study, organization: nil) }

      subject { post :create, params: {case_study: invalid_params} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a CaseStudy' do
        expect { subject }.not_to change(CaseStudy, :count)
      end
    end
  end

  describe 'PATCH update' do
    let!(:case_study_to_update) { create(:case_study) }

    context 'with valid params' do
      let(:valid_update_params) { {organization: 'organization was updated'} }

      subject { patch :update, params: {id: case_study_to_update.id, case_study: valid_update_params} }

      it 'does not create another record' do
        expect { subject }.not_to change(CaseStudy, :count)
      end

      it 'updates existing CaseStudy' do
        expect { subject }.to change { case_study_to_update.reload.organization }.to('organization was updated')
      end

      it 'redirects to the updated CaseStudy' do
        expect(subject).to redirect_to(admin_case_study_path(case_study_to_update))
      end
    end
  end

  def last_case_study_created
    CaseStudy.order(:created_at).last
  end
end
