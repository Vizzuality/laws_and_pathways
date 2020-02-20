require 'rails_helper'

RSpec.describe CCLOW::LegislationAndPoliciesController, type: :controller do
  let!(:legislation1) { create(:legislation, :published, title: 'Super Legislation') }
  let!(:legislation2) { create(:legislation, :published, title: 'Example', description: 'Legislation example') }
  let!(:legislation3) { create(:legislation, :published, title: 'Legislation Example', description: 'Example') }
  let!(:legislation4) { create(:legislation, :draft, title: 'This one is unpublished', description: 'Example') }

  before do
    create(:legislation_event, eventable: legislation1, date: 30.days.ago)
    create(:legislation_event, eventable: legislation1, date: 50.days.ago)

    create(:legislation_event, eventable: legislation2, date: 40.days.ago)
    create(:legislation_event, eventable: legislation2, date: 10.days.ago)

    create(:legislation_event, eventable: legislation3, date: 30.days.ago)
    create(:legislation_event, eventable: legislation3, date: 20.days.ago)
  end

  describe 'GET index' do
    context 'without filters' do
      subject { get :index }

      it { is_expected.to be_successful }

      it('should return all published legislations') do
        subject
        expect(assigns(:legislations).size).to eq(3)
      end

      it('should be ordered by latest date of the event') do
        subject
        expect(assigns(:legislations)).to eq([legislation2, legislation3, legislation1])
      end

      it 'responds to csv' do
        get :index, format: :csv
        expect(response.content_type).to eq('text/csv')
      end
    end

    context 'with query param without matches' do
      let(:params) { {q: 'Query'} }

      subject { get :index, params: params }

      it { is_expected.to be_successful }

      it('should return no legislations') do
        subject
        expect(assigns(:legislations).size).to eq(0)
      end

      it 'responds to csv' do
        get :index, params: params, format: :csv
        expect(response.content_type).to eq('text/csv')
      end
    end

    context 'with query param with matches' do
      let(:params) { {q: 'legislation example'} }
      subject { get :index, params: params }

      it { is_expected.to be_successful }

      it 'should return legislations' do
        subject
        expect(assigns(:legislations).size).to eq(2)
      end

      it('should be ordered by relevance') do
        subject
        expect(assigns(:legislations)).to eq([legislation3, legislation2])
      end

      it 'responds to csv' do
        get :index, params: params, format: :csv
        expect(response.content_type).to eq('text/csv')
      end
    end
  end
end
