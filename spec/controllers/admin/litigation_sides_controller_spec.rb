require 'rails_helper'
require 'csv'

RSpec.describe Admin::LitigationSidesController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:litigation1) { create(:litigation, title: 'Litigation1') }
  let_it_be(:litigation2) { create(:litigation, title: 'Litigation2') }

  let_it_be(:side1) { create(:litigation_side, name: 'Side1', litigation: litigation1) }
  let_it_be(:side2) { create(:litigation_side, name: 'Side2', litigation: litigation2) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to redirect_to(admin_dashboard_path) }
  end

  describe 'GET index with .csv format' do
    before :each do
      get :index, format: 'csv'
    end

    it('returns CSV file') do
      expect(response.header['Content-Type']).to include('text/csv')
    end

    it('returns all sides') do
      csv = response_as_csv
      col_number = csv.headers.index('Name')

      expect(csv.by_col[col_number].sort).to eq(%w[Side1 Side2])
    end
  end

  describe 'GET index with .csv format (query, results present)' do
    before :each do
      get :index,
          params: {
            q: {
              # should narrow down results to 'Event1'
              litigation: {title_eq: 'Litigation1'}
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
      expect(csv[0]['Name']).to eq(side1.name)
    end
  end

  describe 'GET index with .csv format (query, no results)' do
    before :each do
      get :index,
          params: {
            q: {
              # should return no results for that query!
              litigation: {title_eq: 'Litigation2222'}
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
        'Id', 'Litigation id', 'Connected entity type', 'Connected entity id',
        'Name', 'Side type', 'Party type'
      ]
      expect(csv.to_a).to eq([expected_columns])
    end
  end

  def response_as_csv
    CSV.parse(response.body, headers: true)
  end
end
