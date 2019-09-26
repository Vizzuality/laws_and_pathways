require 'rails_helper'

RSpec.describe Admin::TargetsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:target) { create(:target, year: 2030) }
  let!(:target2) { create(:target, year: 2040) }
  let!(:target3) { create(:target, year: 2050) }
  let(:sector) { create(:sector) }
  let(:geography) { create(:geography) }
  let(:target_scope) { create(:target_scope) }
  let(:legislations) { create_list(:legislation, 2) }

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

    it('returns all targets') do
      csv = response_as_csv

      expect(csv.by_col[0].sort).to eq([target.id, target2.id, target3.id].map(&:to_s))
      expect(csv.by_col[4].sort).to eq(%w[2030 2040 2050])
    end
  end

  describe 'GET show' do
    subject { get :show, params: {id: target.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: target.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    let(:valid_attributes) {
      attributes_for(
        :target,
        description: 'Target description',
        year: '2034',
        single_year: true,
        ghg_target: true,
        target_type: 'base_year_target',
        legislation_ids: legislations.pluck(:id),
        geography_id: geography.id,
        sector_id: sector.id,
        target_scope_id: target_scope.id,
        events_attributes: [
          {
            date: 5.days.ago,
            event_type: 'set',
            title: 'Target set',
            description: 'Description 1',
            url: 'https://validurl1.com'
          },
          {
            date: 3.days.ago,
            event_type: 'updated',
            title: 'Target updated',
            description: 'Description 2',
            url: 'https://validurl2.com'
          }
        ]
      )
    }
    let(:invalid_attributes) { valid_attributes.merge(ghg_target: nil) }

    context 'with valid params' do
      subject { post :create, params: {target: valid_attributes} }

      it 'creates a new Target' do
        expect { subject }.to change(Target, :count).by(1)

        expected_events_attrs = [
          ['Target set', 'set', 'Description 1', 'https://validurl1.com'],
          ['Target updated', 'updated', 'Description 2', 'https://validurl2.com']
        ]

        Target.order(:created_at).last.tap do |t|
          expect(t.description).to eq('Target description')
          expect(t.year).to eq(2034)
          expect(t.ghg_target).to eq(true)
          expect(t.single_year).to eq(true)
          expect(t.target_type).to eq('base_year_target')
          expect(t.geography_id).to eq(geography.id)
          expect(t.sector_id).to eq(sector.id)
          expect(t.target_scope_id).to eq(target_scope.id)
          expect(t.legislation_ids).to eq(legislations.pluck(:id))
          expect(
            t.events.order(:date).pluck(:title, :event_type, :description, :url)
          ).to eq(expected_events_attrs)
        end
      end

      it 'redirects to the created Target' do
        expect(subject).to redirect_to(admin_target_path(Target.order(:created_at).last))
      end

      it 'new target is for 2 legislations' do
        subject

        target = Target.order(:created_at).last

        expect(target.legislations.count).to eq(2)
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {target: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Target' do
        expect { subject }.not_to change(Target, :count)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:target) { create(:target, discarded_at: nil) }

    context 'with valid params' do
      let!(:legislation) { create(:legislation) }

      subject { delete :destroy, params: {id: target.id} }

      before do
        target.legislations = [legislation]
        expect { subject }.to change { Target.count }.by(-1)
      end

      it 'set discarded_at date to target object' do
        expect(target.reload.discarded_at).to_not be_nil
      end

      it 'removes discarded target from legislation' do
        expect(target.reload.legislations).to be_empty
      end

      it 'shows proper notice' do
        expect(flash[:notice]).to match('Successfully deleted selected Target')
      end
    end

    context 'with invalid params' do
      let(:command) { double }

      subject { delete :destroy, params: {id: target.id} }

      before do
        expect(::Command::Destroy::Target).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_targets_path)
        expect(flash[:alert]).to match('Could not delete selected Target')
      end
    end
  end

  def response_as_csv
    CSV.parse(response.body, headers: true)
  end
end
