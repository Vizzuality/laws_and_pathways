require 'rails_helper'

# TODO: Extract all importers tests from here to separate files

describe 'CSVDataUpload (integration)' do
  let(:legislations_csv) { fixture_file('legislations.csv') }
  let(:companies_csv) { fixture_file('companies.csv') }
  let(:targets_csv) { fixture_file('targets.csv') }
  let(:cp_benchmarks_csv) { fixture_file('cp_benchmarks.csv') }
  let(:cp_assessments_csv) { fixture_file('cp_assessments.csv') }
  let(:mq_assessments_csv) { fixture_file('mq_assessments.csv') }
  let(:geographies_csv) { fixture_file('geographies.csv') }

  let(:countries) do
    [
      create(:geography, iso: 'POL', name: 'Poland'),
      create(:geography, iso: 'GBR', name: 'United Kingdom'),
      create(:geography, iso: 'JPN', name: 'Japan'),
      create(:geography, iso: 'USA', name: 'United States')
    ]
  end

  let(:current_user_role) { 'publisher_tpi' }
  let(:current_user) { build(:admin_user, role: current_user_role) }

  before do
    ::Current.admin_user = current_user

    countries
  end

  describe 'errors handling' do
    it 'sets error for unknown uploader class' do
      command = Command::CSVDataUpload.new(uploader: 'FooUploader', file: legislations_csv)

      expect(command.call).to eq(false)
      expect(command.errors.to_a).to include('Uploader is not included in the list')
    end

    it 'sets error for missing file' do
      command = Command::CSVDataUpload.new(uploader: 'Legislations', file: nil)

      expect(command.call).to eq(false)
      expect(command.errors.to_a).to include('File is not attached')
    end

    describe 'authorization errors' do
      # Editor should't publish resources
      let(:current_user_role) { 'editor_tpi' }

      let(:legislations_to_publish_csv) { fixture_file('legislations_to_publish.csv') }

      it 'does not import CSV files with Legislation data' do
        # 2nd record (ID=20) should fail with auth error
        csv_content = <<-CSV
          Id,Law,Legislation type,Title,Date passed,Description,Geography,Geography iso,Sector,Frameworks,Document types,Keywords,Natural hazards,Visibility status
          10,101,executive,Finance Act 2,01 Jan 2012,Desc,United Kingdom,GBR,Transport,,Law,"keyword1,keyword2",tsunami,draft
          20,102,legislative,Climate Law,15 Jan 2015,Desc,Poland,POL,Waste,"Mitigation",Law,"keyword1","flooding",published
          30,103,executive,Finance Act 2,01 Jan 2012,Desc,United Kingdom,GBR,Transport,,Law,"keyword1,keyword2",tsunami,pending
        CSV

        command = expect_data_upload_results(
          Legislation,
          fixture_file('legislations.csv', content: csv_content),
          {new_records: 1, not_changed_records: 0, rows: 3, updated_records: 1},
          false
        )

        expect(command.errors.messages[:base])
          .to eq(['Error on row 2: You are not authorized to perform action \'publish\' on Legislation.'])
      end
    end
  end

  it 'imports CSV files with Legislation data' do
    expect_data_upload_results(
      Legislation,
      legislations_csv,
      new_records: 2, not_changed_records: 0, rows: 2, updated_records: 0
    )

    legislation = Legislation.find_by(title: 'Climate Law')

    expect(legislation).to have_attributes(
      legislation_type: 'legislative',
      description: 'Description',
      visibility_status: 'pending'
    )
    expect(legislation.document_types_list).to include('Law')
    expect(legislation.geography.iso).to eq('POL')
    expect(legislation.laws_sectors.count).to eq(1)
    expect(legislation.frameworks.size).to eq(2)
    expect(legislation.frameworks_list).to include('Mitigation', 'Adaptation')
    expect(legislation.keywords.size).to eq(2)
    expect(legislation.keywords_list).to include('Keyword1', 'Keyword3')
    expect(legislation.natural_hazards.size).to eq(2)
    expect(legislation.natural_hazards_list).to include('Sharkinados', 'Flooding')
  end

  it 'imports CSV files with Litigation data' do
    legislation1 = create(:legislation)
    legislation2 = create(:legislation)
    updated_litigation = create(:litigation)

    csv_content = <<-CSV
      Id,Title,Document type,Geography iso,Jurisdiction,Sector,Citation reference number,Summary,Keywords,At issue,Visibility status,Legislation ids
      ,Litigation number 1,administrative_case,GBR,GBR,Transport,EWHC 2752,Lyle requested judicial review,"keyword1,keyword2",At issues,pending,"#{legislation1.id}, #{legislation2.id}"
      #{updated_litigation.id},Litigation number 2,administrative_case,GBR,GBR,,[2013] NIQB 24,The applicants were brothers ...,,,Draft,
    CSV

    litigations_csv = fixture_file('litigations.csv', content: csv_content)

    expect_data_upload_results(
      Litigation,
      litigations_csv,
      new_records: 1, not_changed_records: 0, rows: 2, updated_records: 1
    )

    litigation = Litigation.find_by(title: 'Litigation number 1')

    expect(litigation).to have_attributes(
      citation_reference_number: 'EWHC 2752',
      summary: 'Lyle requested judicial review',
      at_issue: 'At issues',
      visibility_status: 'pending',
      document_type: 'administrative_case'
    )
    expect(litigation.geography.iso).to eq('GBR')
    expect(litigation.laws_sectors.first.name).to eq('Transport')
    expect(litigation.keywords.size).to eq(2)
    expect(litigation.keywords_list).to include('Keyword1', 'Keyword2')
    expect(litigation.legislation_ids).to include(legislation1.id, legislation2.id)
  end

  it 'imports CSV files with Litigation Sides data' do
    litigation1 = create(:litigation)
    litigation2 = create(:litigation, :with_sides)
    updated_side = litigation2.litigation_sides.first
    company = create(:company)
    geography = create(:geography)

    csv_content = <<-CSV
      Id,Litigation id,Connected entity type,Connected entity id,Name,Side type,Party type
      ,#{litigation1.id},Company,#{company.id},#{company.name},a,corporation
      #{updated_side.id},#{litigation2.id},Geography,#{geography.id},Overridden name,b,government
    CSV
    litigation_sides_csv = fixture_file('litigation_sides.csv', content: csv_content)

    expect_data_upload_results(
      LitigationSide,
      litigation_sides_csv,
      new_records: 1, not_changed_records: 0, rows: 2, updated_records: 1
    )

    updated_side.reload
    created_side = litigation1.litigation_sides.first

    expect(litigation1.litigation_sides.size).to eq(1)
    expect(updated_side.connected_entity).to eq(geography)
    expect(updated_side.name).to eq('Overridden name')
    expect(updated_side.party_type).to eq('government')
    expect(updated_side.side_type).to eq('b')

    expect(created_side.connected_entity).to eq(company)
    expect(created_side.name).to eq(company.name)
    expect(created_side.party_type).to eq('corporation')
    expect(created_side.side_type).to eq('a')
  end

  it 'imports CSV file with Event data' do
    litigation_event = create(:litigation_event)
    legislation = create(:legislation)

    csv_content = <<-CSV
      Id,Eventable type,Eventable,Event type,Title,Description,Date,Url
      #{litigation_event.id},Litigation,#{litigation_event.eventable_id},case_decided,Changed title,Changed description,2020-12-30,https://example.com
      ,Legislation,#{legislation.id},approved,title,description,2019-02-20,
    CSV
    events_csv = fixture_file('events.csv', content: csv_content)

    expect_data_upload_results(
      Event,
      events_csv,
      new_records: 1, not_changed_records: 0, rows: 2, updated_records: 1
    )
    expect_data_upload_results(
      Event,
      events_csv,
      new_records: 0, not_changed_records: 2, rows: 2, updated_records: 0
    )

    litigation_event.reload
    created_event = legislation.events.first

    expect(litigation_event).to have_attributes(
      event_type: 'case_decided',
      title: 'Changed title',
      description: 'Changed description',
      date: Date.parse('2020-12-30'),
      url: 'https://example.com'
    )
    expect(created_event).to have_attributes(
      event_type: 'approved',
      title: 'title',
      description: 'description',
      date: Date.parse('2019-02-20'),
      url: nil
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
    # subsequent import should not create or update any record
    expect_data_upload_results(
      CP::Benchmark,
      cp_benchmarks_csv,
      new_records: 0, not_changed_records: 6, rows: 6, updated_records: 0
    )
  end

  it 'imports CSV files with CP Assessments data' do
    acme_company = create(:company, name: 'ACME', id: 1000)
    create(:company, name: 'ACME Materials', id: 2000)

    expect_data_upload_results(
      CP::Assessment,
      cp_assessments_csv,
      new_records: 2, not_changed_records: 0, rows: 2, updated_records: 0
    )
    # subsequent import should not create or update any record
    expect_data_upload_results(
      CP::Assessment,
      cp_assessments_csv,
      new_records: 0, not_changed_records: 2, rows: 2, updated_records: 0
    )

    assessment = acme_company.cp_assessments.last

    expect(assessment.assessment_date).to eq(Date.parse('2019-01-04'))
    expect(assessment.publication_date).to eq(Date.parse('2019-02-01'))
    expect(assessment.last_reported_year).to eq(2018)
    expect(assessment.emissions).to eq(
      '2014' => 101,
      '2015' => 101,
      '2016' => 100,
      '2017' => 101,
      '2018' => 100,
      '2019' => 99,
      '2020' => 98
    )
    expect(assessment.cp_alignment).to eq('Paris Pledges')
  end

  it 'imports CSV files with MQ Assessments data' do
    acme_company = create(:company, name: 'ACME', id: 1000)
    create(:company, name: 'ACME Materials', id: 2000)

    expect_data_upload_results(
      MQ::Assessment,
      mq_assessments_csv,
      new_records: 2, not_changed_records: 0, rows: 2, updated_records: 0
    )
    # subsequent import should not create or update any record
    expect_data_upload_results(
      MQ::Assessment,
      mq_assessments_csv,
      new_records: 0, not_changed_records: 2, rows: 2, updated_records: 0
    )

    assessment = acme_company.mq_assessments.last

    expect(assessment.notes).to eq('notes')
    expect(assessment.level).to eq('2')
    expect(assessment.assessment_date).to eq(Date.parse('2018-01-25'))
    expect(assessment.questions[0].question).to eq('Question one, level 0?')
    expect(assessment.questions[0].level).to eq('0')
    expect(assessment.questions[0].answer).to eq('Yes')
    expect(assessment.questions[1].question).to eq('Question two, level 1?')
    expect(assessment.questions[1].level).to eq('1')
    expect(assessment.questions[1].answer).to eq('Yes')
  end

  it 'import CSV file with Geographies data' do
    # USA is already created
    expect_data_upload_results(
      Geography,
      geographies_csv,
      new_records: 1, not_changed_records: 0, rows: 2, updated_records: 1
    )
    # subsequent import should not create or update any record
    expect_data_upload_results(
      Geography,
      geographies_csv,
      new_records: 0, not_changed_records: 2, rows: 2, updated_records: 0
    )

    geography = Geography.find_by(iso: 'USA')

    expect(geography.legislative_process).to eq('Legislative process USA')
    expect(geography.name).to eq('United States of America')
    expect(geography.region).to eq('North America')
    expect(geography.geography_type).to eq('national')
    expect(geography.visibility_status).to eq('draft')
    expect(geography.political_groups.size).to eq(2)
    expect(geography.political_groups_list).to include('OECD', 'G20')
    expect(geography.federal).to be_truthy
    expect(geography.federal_details).to be
  end

  def expect_data_upload_results(uploaded_resource_klass, csv, expected_details, expected_sucess = true)
    uploader_name = uploaded_resource_klass.name.tr('::', '').pluralize
    command = Command::CSVDataUpload.new(uploader: uploader_name, file: csv)

    expect do
      expect(command).to be_valid
      expect(command.call).to eq(expected_sucess),
                              "Expected import command to #{expected_sucess ? 'succeed' : 'fail'}, but it did not"
      expect(command.details.symbolize_keys).to eq(expected_details)
    end.to change(uploaded_resource_klass, :count).by(expected_details[:new_records])

    command
  end

  def fixture_file(filename, content: nil)
    file_path = "#{Rails.root}/spec/support/fixtures/files/#{filename}"

    if content.present?
      file_path = "#{Rails.root}/tmp/#{filename}"
      File.write(file_path, content)
    end

    Rack::Test::UploadedFile.new(
      file_path,
      'text/csv'
    )
  end
end
