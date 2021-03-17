require 'rails_helper'
require 'csv'

RSpec.describe Admin::EventsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:legislation1) { create(:legislation, visibility_status: 'published') }
  let_it_be(:legislation2) { create(:legislation, visibility_status: 'pending') }
  let_it_be(:litigation1) { create(:litigation, visibility_status: 'published') }
  let_it_be(:litigation2) { create(:litigation, visibility_status: 'draft') }

  let_it_be(:event1) { create(:legislation_event, title: 'Event1', eventable: legislation1) } # with published documentable
  let_it_be(:event2) { create(:legislation_event, title: 'Event2', eventable: legislation2) }
  let_it_be(:event3) { create(:litigation_event, title: 'Event3', eventable: litigation1) } # with published documentable
  let_it_be(:event4) { create(:litigation_event, title: 'Event4', eventable: litigation2) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: event1.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: event1.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET index with .csv format' do
    before :each do
      get :index, format: 'csv'
    end

    it('returns CSV file') do
      expect(response.header['Content-Type']).to include('text/csv')
    end

    it('returns all events') do
      csv = response_as_csv

      expect(csv.by_col[4].sort).to eq(%w[Event1 Event2 Event3 Event4])
    end
  end

  describe 'GET index with .csv format (query, results present)' do
    before :each do
      get :index,
          params: {
            q: {
              # should narrow down results to 'Event1'
              eventable: {visibility_status_eq: 'published'},
              eventable_type_eq: 'Legislation'
            }
          },
          format: 'csv'
    end

    it('returns CSV file') do
      expect(response.header['Content-Type']).to include('text/csv')
    end

    it('returns filtered events list') do
      csv = response_as_csv

      # returned CSV must contain only result row + header
      expect(csv.to_a.size).to eq(2)

      # check filtered data
      expect(csv[0]['Title']).to eq(event1.title)
      expect(csv[0]['Description']).to eq(event1.description)
      expect(csv[0]['Event type']).to eq(event1.event_type.titleize)

      # only single data row
      expect(csv[1]).to be_nil
    end
  end

  describe 'GET index with .csv format (query, no results)' do
    before :each do
      get :index,
          params: {
            q: {
              # should return no results for that query!
              eventable: {visibility_status_eq: 'pending'},
              eventable_type_eq: 'Litigation'
            }
          },
          format: 'csv'
    end

    it('returns CSV file') do
      expect(response.header['Content-Type']).to include('text/csv')
    end

    it('returns empty CSV file (only header)') do
      csv = response_as_csv

      # only header expected
      expected_columns = [
        'Id', 'Eventable type', 'Eventable', 'Event type',
        'Title', 'Description', 'Date', 'Url'
      ]
      expect(csv.to_a).to eq([expected_columns])
    end
  end
end
