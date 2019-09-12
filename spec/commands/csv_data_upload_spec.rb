require 'rails_helper'

describe 'CsvDataUpload (integration)' do
  let(:legislations_simple_csv) { fixture_file('legislations_simple.csv') }
  let(:litigations_simple_csv) { fixture_file('litigations_simple.csv') }
  let(:companies_simple_csv) { fixture_file('companies_simple.csv') }
  let(:targets_csv) { fixture_file('targets.csv') }

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
      command = Command::CsvDataUpload.new(uploader: 'FooUploader', file: legislations_simple_csv)

      expect(command.call).to eq(false)
      expect(command.errors.to_a).to include('Uploader is not included in the list')
    end

    it 'sets error for missing file' do
      command = Command::CsvDataUpload.new(uploader: 'Legislations', file: nil)

      expect(command.call).to eq(false)
      expect(command.errors.to_a).to include('File is not attached')
    end
  end

  it 'imports CSV files with legislations data' do
    command = Command::CsvDataUpload.new(uploader: 'Legislations', file: legislations_simple_csv)

    expect do
      # first import - new records should be created
      expect(command.call).to eq(true)
      expect(command.details.symbolize_keys)
        .to eq(new_records: 2, not_changed_records: 0, rows: 2, updated_records: 0)

      # 2nd subsequent import - nothing should change
      expect(command.call).to eq(true)
      expect(command.details.symbolize_keys)
        .to eq(new_records: 0, not_changed_records: 2, rows: 2, updated_records: 0)
    end.to change(Legislation, :count).by(2)
  end

  it 'imports CSV files with litigations data' do
    command = Command::CsvDataUpload.new(uploader: 'Litigations', file: litigations_simple_csv)

    expect do
      # first import - 2 new records should be created
      expect(command.call).to eq(true)
      expect(command.details.symbolize_keys)
        .to eq(new_records: 4, not_changed_records: 0, rows: 4, updated_records: 0)

      # 2nd subsequent import - nothing should change
      expect(command.call).to eq(true)
      expect(command.details.symbolize_keys)
        .to eq(new_records: 0, not_changed_records: 4, rows: 4, updated_records: 0)
    end.to change(Litigation, :count).by(4)
  end

  it 'imports CSV files with companies data' do
    command = Command::CsvDataUpload.new(uploader: 'Companies', file: companies_simple_csv)

    expect do
      # first import - new records should be created
      expect(command.call).to eq(true)
      expect(command.details.symbolize_keys)
        .to eq(new_records: 7, not_changed_records: 0, rows: 7, updated_records: 0)

      # 2nd subsequent import - nothing should change
      expect(command.call).to eq(true)
      expect(command.details.symbolize_keys)
        .to eq(new_records: 0, not_changed_records: 7, rows: 7, updated_records: 0)
    end.to change(Company, :count).by(7)
  end

  it 'imports CSV files with targets data' do
    command = Command::CsvDataUpload.new(uploader: 'Targets', file: targets_csv)

    expect do
      # first import - new records should be created
      expect(command.call).to eq(true)
      expect(command.details.symbolize_keys)
        .to eq(new_records: 3, not_changed_records: 0, rows: 3, updated_records: 0)
    end.to change(Target, :count).by(3)
  end

  def fixture_file(filename)
    Rack::Test::UploadedFile.new(
      "#{Rails.root}/spec/support/fixtures/files/#{filename}",
      'text/csv'
    )
  end
end
