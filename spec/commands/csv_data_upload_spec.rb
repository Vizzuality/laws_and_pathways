require 'rails_helper'

describe 'CsvDataUpload (integration)' do
  let(:legislations_csv) { fixture_file('legislations.csv') }
  let(:litigations_csv) { fixture_file('litigations.csv') }
  let(:companies_csv) { fixture_file('companies.csv') }
  let(:targets_csv) { fixture_file('targets.csv') }
  let(:cp_benchmarks_csv) { fixture_file('cp_benchmarks.csv') }

  let!(:countries) do
    [
      create(:geography, iso: 'POL'),
      create(:geography, iso: 'GBR'),
      create(:geography, iso: 'JPN'),
      create(:geography, iso: 'USA')
    ]
  end

  let!(:target_scopes) do
    [
      create(:target_scope, name: 'Default Scope'),
      create(:target_scope, name: 'High')
    ]
  end

  describe 'errors handling' do
    it 'sets error for unknown uploader class' do
      command = Command::CsvDataUpload.new(uploader: 'FooUploader', file: legislations_csv)

      expect(command.call).to eq(false)
      expect(command.errors.to_a).to include('Uploader is not included in the list')
    end

    it 'sets error for missing file' do
      command = Command::CsvDataUpload.new(uploader: 'Legislations', file: nil)

      expect(command.call).to eq(false)
      expect(command.errors.to_a).to include('File is not attached')
    end
  end

  it 'imports CSV files with Legislation data' do
    expect_data_upload_results(
      Legislation,
      legislations_csv,
      new_records: 2, not_changed_records: 0, rows: 2, updated_records: 0
    )
  end

  it 'imports CSV files with Litigation data' do
    expect_data_upload_results(
      Litigation,
      litigations_csv,
      new_records: 4, not_changed_records: 0, rows: 4, updated_records: 0
    )
  end

  it 'imports CSV files with Company data' do
    expect_data_upload_results(
      Company,
      companies_csv,
      new_records: 7, not_changed_records: 0, rows: 7, updated_records: 0
    )
  end

  it 'imports CSV files with Target data' do
    expect_data_upload_results(
      Target,
      targets_csv,
      new_records: 3, not_changed_records: 0, rows: 3, updated_records: 0
    )
  end

  it 'imports CSV files with CP Benchmarks data' do
    expect_data_upload_results(
      CP::Benchmark,
      cp_benchmarks_csv,
      new_records: 6, not_changed_records: 0, rows: 6, updated_records: 0
    )
  end

  def expect_data_upload_results(uploaded_resource_klass, csv, expected_details)
    uploader_name = uploaded_resource_klass.name.tr('::', '').pluralize
    command = Command::CsvDataUpload.new(uploader: uploader_name, file: csv)

    expect do
      expect(command.call).to eq(true)
      expect(command.details.symbolize_keys).to eq(expected_details)
    end.to change(uploaded_resource_klass, :count).by(expected_details[:new_records])
  end

  def fixture_file(filename)
    Rack::Test::UploadedFile.new(
      "#{Rails.root}/spec/support/fixtures/files/#{filename}",
      'text/csv'
    )
  end
end
