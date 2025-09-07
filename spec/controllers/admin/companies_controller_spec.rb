require 'rails_helper'

RSpec.describe Admin::CompaniesController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:geography) { create(:geography) }
  let_it_be(:company) { create(:company, :with_mq_assessments, :with_cp_assessments, geography: geography) }
  let_it_be(:sector) { create(:tpi_sector) }
  let(:valid_attributes) {
    attributes_for(:company).merge(
      geography_id: geography.id, headquarters_geography_id: geography.id, sector_id: sector.id
    )
  }
  let(:invalid_attributes) { valid_attributes.merge(isin: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET index with .csv format' do
    before :each do
      get :index, format: 'csv'
    end

    it('returns CSV file') do
      expect(response.header['Content-Type']).to include('text/csv')
    end
  end

  describe 'GET show' do
    subject { get :show, params: {id: company.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: company.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {company: valid_attributes} }

      it 'creates a new Company' do
        expect { subject }.to change(Company, :count).by(1)
      end

      it 'redirects to the created Company' do
        expect(subject).to redirect_to(admin_company_path(Company.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {company: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Company' do
        expect { subject }.not_to change(Company, :count)
      end
    end
  end

  describe 'PATCH update' do
    let!(:company_to_update) { create(:company, geography: geography) }

    context 'with valid params' do
      let(:valid_update_params) { {name: 'name was updated'} }

      subject { patch :update, params: {id: company_to_update.id, company: valid_update_params} }

      it 'does not create another record' do
        expect { subject }.not_to change(Company, :count)
      end

      it 'updates existing Company' do
        expect { subject }.to change { company_to_update.reload.name }.to('name was updated')
      end

      it 'creates "edited" activity' do
        expect { subject }.to change(PublicActivity::Activity, :count).by(1)

        expect(PublicActivity::Activity.last.trackable_id).to eq(company_to_update.id)
        expect(PublicActivity::Activity.last.key).to eq('company.edited')
      end

      it 'redirects to the updated Company' do
        expect(subject).to redirect_to(admin_company_path(company_to_update))
      end
    end
  end

  describe 'DELETE destroy' do
    render_views false

    let!(:company) { create(:company, geography: geography, discarded_at: nil) }

    context 'with valid params' do
      let!(:litigation_side) do
        create(:litigation_side, connected_entity_type: 'Company', connected_entity_id: company.id)
      end
      let!(:mq_assessment) { create(:mq_assessment, company: company) }
      let!(:cp_assessment) { create(:cp_assessment, cp_assessmentable: company) }

      subject { delete :destroy, params: {id: company.id} }

      before do
        expect { subject }.to change { Company.count }.by(-1)
      end

      it 'discards company object' do
        expect(Company.find_by_id(company.id)).to be_nil
      end

      it 'set discarded_at date to company object' do
        expect(company.reload.discarded_at).to_not be_nil
      end

      it 'discard all litigation_sides' do
        expect(LitigationSide.find_by_id(litigation_side.id)).to be_nil
      end

      it 'discard all mq_assessment' do
        expect(MQ::Assessment.find_by_id(mq_assessment.id)).to be_nil
      end

      it 'discard all cp_assessment' do
        expect(CP::Assessment.find_by_id(cp_assessment.id)).to be_nil
      end

      it 'shows proper notice' do
        expect(flash[:notice]).to match('Successfully deleted selected Company')
      end
    end

    context 'with invalid params' do
      let(:command) { double }

      subject { delete :destroy, params: {id: company.id} }

      before do
        expect(Command::Destroy::Company).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_companies_path)
        expect(flash[:alert]).to match('Could not delete selected Company')
      end
    end
  end
end
