require 'rails_helper'
require 'csv'

RSpec.describe Admin::DocumentsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:legislation1) { create(:legislation, visibility_status: 'published') }
  let_it_be(:legislation2) { create(:legislation, visibility_status: 'pending') }
  let_it_be(:litigation1) { create(:litigation, visibility_status: 'published') }
  let_it_be(:litigation2) { create(:litigation, visibility_status: 'draft') }

  let_it_be(:document1) { create(:document, name: 'Doc1', documentable: legislation1) } # with published documentable
  let_it_be(:document2) { create(:document, name: 'Doc2', documentable: legislation2) }
  let_it_be(:document3) { create(:document, name: 'Doc3', documentable: litigation1) }  # with published documentable
  let_it_be(:document4) { create(:document, name: 'Doc4', documentable: litigation2) }

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

    it('returns all documents') do
      csv = response_as_csv

      expect(csv.by_col[1].sort).to eq(%w[Doc1 Doc2 Doc3 Doc4])
    end
  end

  describe 'GET index with .csv format (query, results present)' do
    before :each do
      get :index,
          params: {
            q: {
              # should narrow down results to document1
              documentable: {visibility_status_eq: 'published'},
              documentable_type_eq: 'Legislation'
            }
          },
          format: 'csv'
    end

    it('returns CSV file') do
      expect(response.header['Content-Type']).to include('text/csv')
    end

    it('returns filtered documents list') do
      csv = response_as_csv

      # returned CSV must contain only result row + header
      expect(csv.to_a.size).to eq(2)

      # check filtered data
      expect(csv[0]['Name']).to eq(document1.name)
      expect(csv[0]['Documentable type']).to eq(document1.documentable_type)

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
              documentable: {visibility_status_eq: 'pending'},
              documentable_type_eq: 'Litigation'
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
        'Id', 'Name', 'External url',
        'Language', 'Last verified on',
        'Documentable id', 'Documentable type'
      ]
      expect(csv.to_a).to eq([expected_columns])
    end
  end

  describe 'GET show' do
    subject { get :show, params: {id: document1.id} }

    it { is_expected.to be_successful }
  end
end
