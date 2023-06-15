require 'rails_helper'

# TODO: Extract all importers tests from here to separate files

describe 'CSVDataUpload (integration)' do
  let(:banks_csv) { fixture_file('banks.csv') }
  let(:bank_assessment_indicators_csv) { fixture_file('bank_assessment_indicators.csv') }
  let(:bank_assessments_csv) { fixture_file('bank_assessments.csv') }
  let(:companies_csv) { fixture_file('companies.csv') }
  let(:cp_benchmarks_csv) { fixture_file('cp_benchmarks.csv') }
  let(:company_cp_assessments_csv) { fixture_file('company_cp_assessments.csv') }
  let(:bank_cp_assessments_csv) { fixture_file('bank_cp_assessments.csv') }
  let(:mq_assessments_csv) { fixture_file('mq_assessments.csv') }
  let(:geographies_csv) { fixture_file('geographies.csv') }
  let(:current_user_role) { 'super_user' }
  let(:current_user) { build(:admin_user, role: current_user_role) }
  let_it_be(:countries) do
    [
      create(:geography, iso: 'POL', name: 'Poland'),
      create(:geography, iso: 'GBR', name: 'United Kingdom'),
      create(:geography, iso: 'JPN', name: 'Japan'),
      create(:geography, iso: 'USA', name: 'United States')
    ]
  end

  before do
    ::Current.admin_user = current_user
  end

  after do
    ::Current.admin_user = nil
  end

  describe 'errors handling' do
    before(:each) { allow_any_instance_of(Kernel).to receive(:warn) } # suppress warning message

    it 'sets error for unknown uploader class' do
      command = Command::CSVDataUpload.new(uploader: 'FooUploader', file: companies_csv)

      expect(command.call).to eq(false)
      expect(command.errors.to_a).to include('Uploader is not included in the list')
    end

    it 'sets error for missing file' do
      command = Command::CSVDataUpload.new(uploader: 'Legislations', file: nil)

      expect(command.call).to eq(false)
      expect(command.errors.to_a).to include('File is not attached')
    end

    it 'sets error when accessing missing header data' do
      csv_content = <<-CSV
        Title,Document type,Geography iso,Jurisdiction,Sectors,Citation reference number,Summary wrong header,responses,Keywords,At issue,Visibility status,Legislation ids
        Litigation number 1,administrative_case,GBR,GBR,Transport,EWHC 2752,Lyle requested judicial review,"response1;response2","keyword1;keyword2",At issues,pending,
      CSV

      command = expect_data_upload_results(
        Litigation,
        fixture_file('litigations.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false
      )

      expect(command.errors.messages[:base])
        .to eq(['CSV missing header: Id'])
    end

    it 'sets error when wrong date format is used' do
      to_update = create(:cp_assessment, company: create(:company))
      csv_content = <<-CSV
        Id,Assessment Date
        #{to_update.id},1/14/2021
      CSV

      command = expect_data_upload_results(
        CP::Assessment,
        fixture_file('company_cp_assessments.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false,
        custom_uploader: 'CompanyCPAssessments'
      )
      expect(command.errors.messages[:base])
        .to eq(['Error on row 1: Cannot parse date: 1/14/2021, expected formats: %Y-%m-%d, %d/%m/%Y.'])
    end

    describe 'Legislation errors' do
      before :each do
        create(:document_type, name: 'Law')
      end

      it 'sets error when instrument type is missing' do
        csv_content = <<~CSV
          "Id","Legislation type","Title","Parent Id","Date passed","Description","Geography","Geography iso","Sectors","Frameworks","Document types","Keywords","Responses","Natural hazards","Instruments","Themes","Litigation ids","Visibility status"
          ,"executive","Finance Act 2011",,"01 Jan 2012","Description","United Kingdom","GBR","Transport",,"Law",,,,"instrument|existing type",,,"draft"
        CSV

        command = expect_data_upload_results(
          Legislation,
          fixture_file('legislations.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
          expected_success: false
        )

        expect(command.errors.messages[:base])
          .to eq(['Error on row 1: Cannot find Instrument Type: existing type.'])
      end

      it 'sets error when instrument is missing' do
        create(:instrument_type, name: 'Existing type')
        csv_content = <<~CSV
          "Id","Legislation type","Title","Parent Id","Date passed","Description","Geography","Geography iso","Sectors","Frameworks","Document types","Keywords","Responses","Natural hazards","Instruments","Themes","Litigation ids","Visibility status"
           ,"executive","Finance Act 2011",,"01 Jan 2012","Description","United Kingdom","GBR","Transport",,"Law",,,,"instrument|existing type",,,"draft"
        CSV

        command = expect_data_upload_results(
          Legislation,
          fixture_file('legislations.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
          expected_success: false
        )

        expect(command.errors.messages[:base])
          .to eq(["Error on row 1: Cannot find Instrument: 'instrument' of type 'Existing type'."])
      end

      it 'sets error when theme type is missing' do
        csv_content = <<~CSV
          "Id","Legislation type","Title","Parent Id","Date passed","Description","Geography","Geography iso","Sectors","Frameworks","Document types","Keywords","Responses","Natural hazards","Instruments","Themes","Litigation ids","Visibility status"
           ,"executive","Finance Act 2011",,"01 Jan 2012","Description","United Kingdom","GBR","Transport",,"Law",,,,,"Existing theme|Existing theme type",,"draft"
        CSV

        command = expect_data_upload_results(
          Legislation,
          fixture_file('legislations.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
          expected_success: false
        )

        expect(command.errors.messages[:base])
          .to eq(['Error on row 1: Cannot find Theme Type: Existing theme type.'])
      end

      it 'sets error when theme is missing' do
        create(:theme_type, name: 'Existing theme type')
        csv_content = <<~CSV
          "Id","Legislation type","Title","Parent Id","Date passed","Description","Geography","Geography iso","Sectors","Frameworks","Document types","Keywords","Responses","Natural hazards","Instruments","Themes","Litigation ids","Visibility status"
           ,"executive","Finance Act 2011",,"01 Jan 2012","Description","United Kingdom","GBR","Transport",,"Law",,,,,"Existing theme|Existing theme type",,"draft"
        CSV

        command = expect_data_upload_results(
          Legislation,
          fixture_file('legislations.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
          expected_success: false
        )

        expect(command.errors.messages[:base])
          .to eq(["Error on row 1: Cannot find Theme: 'Existing theme' of type 'Existing theme type'."])
      end
    end

    describe 'authorization errors' do
      let(:csv_content) do
        <<-CSV
          Id,Law Id,Legislation type,Title,Date passed,Description,Geography,Geography iso,Sectors,Frameworks,Document types,Keywords,Responses,Natural hazards,Visibility status
          10,101,executive,Finance Act 2,01 Jan 2012,Desc,United Kingdom,GBR,Transport,,Law,,,,draft
          20,102,legislative,Climate Law,15 Jan 2015,Desc,Poland,POL,Waste,,Law,,,,published
          30,103,executive,Finance Act 2,01 Jan 2012,Desc,United Kingdom,GBR,Transport,,Law,,,,pending
        CSV
      end

      before(:each) do
        create(:document_type, name: 'Law')
      end

      context 'when user cannot import' do
        # Editor should't publish resources
        let(:current_user_role) { 'editor_tpi' }

        it 'does not import anything from CSV file with Legislation data' do
          # 2nd record (ID=20) should fail with auth error
          command = expect_data_upload_results(
            Legislation,
            fixture_file('legislations.csv', content: csv_content),
            {new_records: 0, not_changed_records: 0, rows: 3, updated_records: 0},
            expected_success: false
          )

          expect(command.errors.messages[:base])
            .to eq(['User not authorized to import Legislation'])
        end
      end

      context 'when user cannot publish through import' do
        # Editor should't publish resources
        let(:current_user_role) { 'editor_laws' }

        it 'does not at all if one row is not valid' do
          allow_any_instance_of(Kernel).to receive(:warn) # suppress warning message
          # 2nd record (ID=20) should fail with auth error
          command = expect_data_upload_results(
            Legislation,
            fixture_file('legislations.csv', content: csv_content),
            {new_records: 0, not_changed_records: 0, rows: 3, updated_records: 0},
            expected_success: false
          )

          expect(command.errors.messages[:base])
            .to eq(['Error on row 2: Validation failed: You are not authorized to publish/unpublish this Entity.'])
        end
      end
    end
  end

  describe 'encoding' do
    it 'correctly imports files with BOM UTF-8' do
      csv_content = <<~CSV
        "Id","Name","ISIN","Sedol","Sector id","Sector","Market Cap Group","Geography iso","Geography","Headquarters geography iso","Headquarters geography","Company comments internal","Latest information","active","CA100","Visibility status"
        "69","Consol Energy","US20854P1093",,"2","Coal Mining","small","USA","United States of America","USA","United States of America",,,TRUE,"true","published"
        "74","Daio Paper","JP3440400004,23783837783",,"14","Paper","small","JPN","Japan","JPN","Japan",,,TRUE,"false","draft"
        "81","Domtar","US2575592033",,"14","Paper","small","USA","United States of America","USA","United States of America",,,TRUE,"false","draft"
      CSV

      expect_data_upload_results(
        Company,
        fixture_file('companies.csv', content: csv_content, add_bom: true),
        new_records: 3, not_changed_records: 0, rows: 3, updated_records: 0
      )
    end

    it 'fixes wrong unicode characters' do
      csv_content = <<~CSV
        Id,Title,Document type,Geography iso,Jurisdiction,Sectors,Citation reference number,Summary,responses,Keywords,At issue,Visibility status,Legislation ids
        ,Litigation number 1 â€žquoteâ€,administrative_case,GBR,GBR,"Transport,Energy;Urban",EWHC 2752,Lyle requested judicial review,,,At issues,pending,
      CSV

      litigations_csv = fixture_file('litigations.csv', content: csv_content)

      expect_data_upload_results(
        Litigation,
        litigations_csv,
        new_records: 1, not_changed_records: 0, rows: 1, updated_records: 0
      )

      litigation = Litigation.find_by(citation_reference_number: 'EWHC 2752')

      expect(litigation.title).to eq('Litigation number 1 „quote”')
    end
  end

  it 'imports CSV files with Legislation data' do
    parent_legislation = create(:legislation)
    existing_instrument_type = create(:instrument_type, name: 'Existing Type')
    gov_planning_instrument_type = create(:instrument_type, name: 'Governance and planning')
    regulation_instrument_type = create(:instrument_type, name: 'Regulation')
    create(:instrument, instrument_type: existing_instrument_type, name: 'Instrument')
    create(:instrument, instrument_type: existing_instrument_type, name: 'Monitoring and evaluation')
    create(:instrument, instrument_type: gov_planning_instrument_type, name: 'Climate fund')
    create(:instrument, instrument_type: regulation_instrument_type, name: 'Building codes')
    existing_theme_type = create(:theme_type, name: 'Existing Theme Type')
    new_theme_type = create(:theme_type, name: 'new theme type')
    create(:theme, theme_type: existing_theme_type, name: 'Existing Theme')
    create(:theme, theme_type: existing_theme_type, name: 'theme 2')
    create(:theme, theme_type: new_theme_type, name: 'theme 1')
    litigation1 = create(:litigation)
    litigation2 = create(:litigation)

    create(:keyword, name: 'keyword1')
    create(:keyword, name: 'keyword2')
    create(:response, name: 'Response1')
    create(:response, name: 'response2')
    create(:framework, name: 'Mitigation')
    create(:framework, name: 'adaptation')
    create(:natural_hazard, name: 'tsunami')
    create(:natural_hazard, name: 'flooding')
    create(:document_type, name: 'Law')

    csv_content = <<~CSV
      "Id","Legislation type","Title","Parent Id","Date passed","Description","Geography","Geography iso","Sectors","Frameworks","Document types","Keywords","Responses","Natural hazards","Instruments","Themes","Litigation ids","Visibility status"
       ,"executive","Finance Act 2011",,"01 Jan 2012","Description","United Kingdom","GBR","Transport",,"Law","keyword1;Keyword2","Response1;response2","tsunami","instrument|existing type","Existing theme|Existing theme type",,"draft"
       ,"legislative","Climate Law",#{parent_legislation.id},"15 Jan 2015","Description","Poland","POL","Waste","Mitigation;Adaptation","Law","keyword1","response1","flooding","Monitoring and evaluation|existing Type;Climate fund|Governance and planning;Building codes | Regulation","theMe 1|new theme type;theme 2|existing theme type","#{litigation1.id};#{litigation2.id}","pending"
    CSV

    expect_data_upload_results(
      Legislation,
      fixture_file('legislations.csv', content: csv_content),
      new_records: 2, not_changed_records: 0, rows: 2, updated_records: 0
    )

    legislation = Legislation.find_by(title: 'Climate Law')

    expect(legislation).to have_attributes(
      legislation_type: 'legislative',
      description: 'Description',
      visibility_status: 'pending',
      parent_id: parent_legislation.id
    )
    expect(legislation.document_types_list).to include('Law')
    expect(legislation.geography.iso).to eq('POL')
    expect(legislation.laws_sectors.count).to eq(1)
    expect(legislation.frameworks.size).to eq(2)
    expect(legislation.frameworks_list).to include('Mitigation', 'adaptation')
    expect(legislation.keywords.size).to eq(1)
    expect(legislation.keywords_list).to include('keyword1')
    expect(legislation.responses.size).to eq(1)
    expect(legislation.responses_list).to include('Response1')
    expect(legislation.natural_hazards.size).to eq(1)
    expect(legislation.natural_hazards_list).to include('flooding')
    expect(legislation.litigations.size).to eq(2)
    expect(legislation.litigation_ids).to include(litigation1.id, litigation2.id)
    expect(legislation.instruments.map(&:name))
      .to contain_exactly('Monitoring and evaluation', 'Climate fund', 'Building codes')
    expect(InstrumentType.all.pluck(:name)).to contain_exactly('Governance and planning', 'Regulation', 'Existing Type')
    expect(existing_instrument_type.instruments.map(&:name)).to contain_exactly('Instrument', 'Monitoring and evaluation')
    expect(legislation.themes.map(&:name)).to contain_exactly('theme 1', 'theme 2')
    expect(ThemeType.all.pluck(:name)).to contain_exactly('new theme type', 'Existing Theme Type')
    expect(existing_theme_type.themes.map(&:name)).to contain_exactly('Existing Theme', 'theme 2')

    legislation2 = Legislation.find_by(title: 'Finance Act 2011')
    expect(legislation2.instruments.map(&:name)).to contain_exactly('Instrument')
    expect(legislation2.themes.map(&:name)).to contain_exactly('Existing Theme')
  end

  describe 'required columns return error' do
    it 'for Legislations' do
      csv_content = <<-CSV
        Title,Parent Id
        New title for legislation,
      CSV

      command = expect_data_upload_results(
        Legislation,
        fixture_file('legislations.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id'])
    end

    it 'for External Legislations' do
      csv_content = <<-CSV
        Name
        New Name
      CSV

      command = expect_data_upload_results(
        ExternalLegislation,
        fixture_file('external-legislations.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id'])
    end

    it 'for Targets' do
      csv_content = <<-CSV
        Target type
        fixed_level_target
      CSV

      command = expect_data_upload_results(
        Target,
        fixture_file('targets.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id'])
    end

    it 'for Litigations' do
      csv_content = <<-CSV
        Title
        New title for litigation
      CSV

      command = expect_data_upload_results(
        Litigation,
        fixture_file('litigations.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id'])
    end

    it 'for Litigation Sides' do
      csv_content = <<-CSV
        Name,Connected Entity Id
        New side name, 12
      CSV

      command = expect_data_upload_results(
        LitigationSide,
        fixture_file('litigation-sides.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id', 'CSV missing header: Connected entity type'])
    end

    it 'for Geographies' do
      csv_content = <<-CSV
        Name
        New Name
      CSV

      command = expect_data_upload_results(
        Geography,
        fixture_file('geographies.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id'])
    end

    it 'for Companies' do
      csv_content = <<-CSV
        Name
        New Name
      CSV

      command = expect_data_upload_results(
        Company,
        fixture_file('companies.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id'])
    end

    it 'for MQ Assessments' do
      csv_content = <<-CSV
        Publication Date
        2020-01
      CSV

      command = expect_data_upload_results(
        MQ::Assessment,
        fixture_file('mq-assessments.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id'])
    end

    it 'for Company CP Assessments' do
      csv_content = <<-CSV
        Publication Date
        2020-01
      CSV

      command = expect_data_upload_results(
        CP::Assessment,
        fixture_file('company-cp-assessments.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false,
        custom_uploader: 'CompanyCPAssessments'
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id'])
    end

    it 'for Bank CP Assessments' do
      csv_content = <<-CSV
        Publication Date
        2020-01
      CSV

      command = expect_data_upload_results(
        CP::Assessment,
        fixture_file('bank-cp-assessments.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false,
        custom_uploader: 'BankCPAssessments'
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id'])
    end

    it 'for Events' do
      csv_content = <<-CSV
        Title, Eventable Type
        New event title,Geography
      CSV

      command = expect_data_upload_results(
        Event,
        fixture_file('events.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id', 'CSV missing header: Eventable id'])
    end

    it 'for CP Benchmarks' do
      csv_content = <<-CSV
        Scenario
        2 degrees
      CSV

      command = expect_data_upload_results(
        CP::Benchmark,
        fixture_file('cp_benchmarks.csv', content: csv_content),
        {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 0},
        expected_success: false
      )

      expect(command.errors.messages[:base]).to eq(['CSV missing header: Id'])
    end
  end

  describe 'partial updates' do
    it 'works for Legislations' do
      parent = create(:legislation)
      to_update = create(:legislation, parent: parent)
      csv_content = <<-CSV
        Id,Title,Parent Id
        #{to_update.id},New title for legislation,
      CSV

      expect_to_change = [:title, :slug, :tsv, :updated_at, :parent_id]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change),
        :tag_ids, :event_ids, :instrument_ids, :theme_ids, :target_ids, :litigation_ids
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          Legislation,
          fixture_file('legislations.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true
        )
        to_update.reload
      end
    end

    it 'works for Legislation updating tags' do
      create(:keyword, name: 'new keyword1')
      create(:keyword, name: 'New keyword2')

      to_update = create(:legislation)
      csv_content = <<-CSV
        Id,Keywords
        #{to_update.id},New Keyword1;New Keyword2
      CSV

      expect_to_change = [:keyword_ids]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change),
        :event_ids, :instrument_ids, :theme_ids, :target_ids, :litigation_ids
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          Legislation,
          fixture_file('legislations.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true
        )
        to_update.reload
      end
    end

    it 'works for Litigations' do
      to_update = create(:litigation)
      csv_content = <<-CSV
        Id,Title
        #{to_update.id},New title for litigation
      CSV

      expect_to_change = [:title, :slug, :tsv, :updated_at]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change),
        :tag_ids, :event_ids, :legislation_ids, :external_legislation_ids, :laws_sector_ids
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          Litigation,
          fixture_file('litigations.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true
        )
        to_update.reload
      end
    end

    it 'works for Litigation Sides' do
      to_update = create(:litigation_side)
      csv_content = <<-CSV
        Id,Name
        #{to_update.id},New side name
      CSV

      expect_to_change = [:name, :updated_at]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change)
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          LitigationSide,
          fixture_file('litigation-sides.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true
        )
        to_update.reload
      end
    end

    it 'works for Targets' do
      to_update = create(:target)
      csv_content = <<-CSV
        Id,Target type
        #{to_update.id},fixed_level_target
      CSV

      expect_to_change = [:target_type, :updated_at]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change),
        :tag_ids, :event_ids, :legislation_ids
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          Target,
          fixture_file('targets.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true
        )
        to_update.reload
      end
    end

    it 'works for External Legislations' do
      to_update = create(:external_legislation)
      csv_content = <<-CSV
        Id,Name
        #{to_update.id},New Name
      CSV

      expect_to_change = [:name, :updated_at]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change),
        :litigation_ids
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          ExternalLegislation,
          fixture_file('external-laws.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true
        )
        to_update.reload
      end
    end

    it 'works for Events' do
      to_update = create(:litigation_event)
      csv_content = <<-CSV
        Id,Title
        #{to_update.id},New event title
      CSV

      expect_to_change = [:title]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change)
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          Event,
          fixture_file('events.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true
        )
        to_update.reload
      end
    end

    it 'works for Geographies' do
      to_update = create(:geography)
      csv_content = <<-CSV
        Id,Name
        #{to_update.id},New Name
      CSV

      expect_to_change = [:name, :slug, :updated_at]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change),
        :tag_ids, :event_ids, :legislation_ids, :litigation_ids, :target_ids
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          Geography,
          fixture_file('geographies.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true
        )
        to_update.reload
      end
    end

    it 'works for Companies' do
      to_update = create(:company)
      csv_content = <<-CSV
        Id,Name
        #{to_update.id},New Name
      CSV

      expect_to_change = [:name, :slug, :updated_at]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change)
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          Company,
          fixture_file('companies.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true
        )
        to_update.reload
      end
    end

    it 'works for CP Benchmarks' do
      to_update = create(:cp_benchmark)
      csv_content = <<-CSV
        Id,Scenario
        #{to_update.id},2 degrees
      CSV

      expect_to_change = [:scenario, :updated_at]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change)
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          CP::Benchmark,
          fixture_file('cp_benchmarks.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true
        )
        to_update.reload
      end
    end

    it 'works for Company CP Assessments' do
      to_update = create(:cp_assessment, company: create(:company))
      csv_content = <<-CSV
        Id,Publication Date
        #{to_update.id},2020-01
      CSV

      expect_to_change = [:publication_date, :updated_at]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change)
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          CP::Assessment,
          fixture_file('company_cp_assessments.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true,
          custom_uploader: 'CompanyCPAssessments'
        )
        to_update.reload
      end
    end

    it 'works for Bank CP Assessments' do
      to_update = create(:cp_assessment, cp_assessmentable: create(:bank))
      csv_content = <<-CSV
        Id,Publication Date
        #{to_update.id},2020-01
      CSV

      expect_to_change = [:publication_date, :updated_at]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change)
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          CP::Assessment,
          fixture_file('bank_cp_assessments.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true,
          custom_uploader: 'BankCPAssessments'
        )
        to_update.reload
      end
    end

    it 'works for MQ Assessments' do
      to_update = create(:mq_assessment, company: create(:company))
      csv_content = <<-CSV
        Id,Publication Date
        #{to_update.id},2020-01
      CSV

      expect_to_change = [:publication_date, :updated_at]
      expect_not_to_change = [
        *(to_update.attributes.symbolize_keys.keys - expect_to_change)
      ]

      expect_changes(to_update, expect_to_change, expect_not_to_change) do
        expect_data_upload_results(
          MQ::Assessment,
          fixture_file('mq_assessments.csv', content: csv_content),
          {new_records: 0, not_changed_records: 0, rows: 1, updated_records: 1},
          expected_success: true
        )
        to_update.reload
      end
    end
  end

  it 'imports CSV files with Litigation data' do
    legislation1 = create(:legislation)
    legislation2 = create(:legislation)
    updated_litigation = create(:litigation)

    create(:keyword, name: 'Keyword1')
    create(:keyword, name: 'Keyword2')
    create(:response, name: 'Response1')
    create(:response, name: 'Response2')

    csv_content = <<-CSV
      Id,Title,Document type,Geography iso,Jurisdiction,Sectors,Citation reference number,Summary,responses,Keywords,At issue,Visibility status,Legislation ids
      ,Litigation number 1,administrative_case,GBR,GBR,"Transport;Energy;Urban",EWHC 2752,Lyle requested judicial review,"response1;response2","keyword1;keyword2",At issues,pending,"#{legislation1.id};#{legislation2.id}"
      #{updated_litigation.id},Litigation number 2,administrative_case,GBR,GBR,,[2013] NIQB 24,The applicants were brothers ...,,,,Draft,
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
    expect(litigation.laws_sectors.pluck(:name)).to include('Transport', 'Energy', 'Urban')
    expect(litigation.keywords.size).to eq(2)
    expect(litigation.keywords_list).to include('Keyword1', 'Keyword2')
    expect(litigation.responses.size).to eq(2)
    expect(litigation.responses_list).to include('Response1', 'Response2')
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

  it 'imports CSV files with Documents data' do
    legislation = create(:legislation)

    csv_content = <<-CSV
      Id,Name,External url,Language,Last verified on,Documentable id,Documentable type
      ,Document name,http://example.com,English,03/12/2020,#{legislation.id},Legislation
    CSV
    documents_csv = fixture_file('documents.csv', content: csv_content)

    expect_data_upload_results(
      Document,
      documents_csv,
      new_records: 1, not_changed_records: 0, rows: 1, updated_records: 0
    )

    created = Document.last

    expect(created.name).to eq('Document name')
    expect(created.external_url).to eq('http://example.com')
    expect(created.last_verified_on).to eq(Date.parse('2020-12-03'))
    expect(legislation.documents.first).to eq(created)
  end

  it 'imports CSV files with External Legislation data' do
    litigation1 = create(:litigation)
    litigation2 = create(:litigation)

    csv_content = <<-CSV
      Id,Name,url,Geography iso,Litigation ids
      ,External law 1,http://example.com,POL,"#{litigation1.id};#{litigation2.id}"
    CSV
    external_laws_csv = fixture_file('external_laws.csv', content: csv_content)

    expect_data_upload_results(
      ExternalLegislation,
      external_laws_csv,
      new_records: 1, not_changed_records: 0, rows: 1, updated_records: 0
    )

    created = ExternalLegislation.last

    expect(created.name).to eq('External law 1')
    expect(created.url).to eq('http://example.com')
    expect(created.geography.iso).to eq('POL')
    expect(litigation1.external_legislation_ids).to include(created.id)
    expect(litigation2.external_legislation_ids).to include(created.id)
  end

  it 'imports CSV file with Event data' do
    litigation_event = create(:litigation_event)
    legislation = create(:legislation)

    csv_content = <<-CSV
      Id,Eventable type,Eventable Id,Event type,Title,Description,Date,Url
      #{litigation_event.id},Litigation,#{litigation_event.eventable_id},closed,Changed title,Changed description,2020-12-30,https://example.com
      ,Legislation,#{legislation.id},passed/approved,title,description,2019-02-20,
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
      event_type: 'closed',
      title: 'Changed title',
      description: 'Changed description',
      date: Date.parse('2020-12-30'),
      url: 'https://example.com'
    )
    expect(created_event).to have_attributes(
      event_type: 'passed/approved',
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
    updated_target = create(:target, source: 'plan')
    law = create(:legislation)
    law2 = create(:legislation)

    create(:scope, name: 'Scope1')
    create(:scope, name: 'Scope2')

    csv_content = <<-CSV
      Id,Target type,Description,Ghg target,Year,Base year period,Single year,Geography,Geography iso,Sector,Scopes,source,Legislation ids,Visibility status
      ,no_document_submitted,description,true,1995,1998,false,Japan,JPN,Airlines,"Scope2",law,,draft
      #{updated_target.id},base_year_target,updated description,true,1994,1994,false,Poland,POL,Cement,"Scope1;Scope2",ndc,"#{law.id};#{law2.id}",draft
      ,intensity_target_and_trajectory_target,description,false,2003,2001,true,Poland,POL,Electricity Utilities,"Scope1",plan,#{law.id},pending
    CSV

    targets_csv = fixture_file('targets.csv', content: csv_content)

    expect_data_upload_results(
      Target,
      targets_csv,
      new_records: 2, not_changed_records: 0, rows: 3, updated_records: 1
    )

    updated_target.reload

    expect(updated_target).to have_attributes(
      target_type: 'base_year_target',
      description: 'updated description',
      ghg_target: true,
      year: 1994,
      base_year_period: '1994',
      single_year: false,
      source: 'ndc',
      visibility_status: 'draft'
    )
    expect(updated_target.geography.name).to eq('Poland')
    expect(updated_target.sector.name).to eq('Cement')
    expect(updated_target.scopes.size).to eq(2)
    expect(updated_target.scopes_list).to include('Scope1', 'Scope2')
    expect(updated_target.legislations.size).to eq(2)
    expect(updated_target.legislation_ids).to include(law.id, law2.id)

    latest = Target.last

    expect(latest).to have_attributes(
      target_type: 'intensity_target_and_trajectory_target',
      description: 'description',
      ghg_target: false,
      year: 2003,
      base_year_period: '2001',
      single_year: true,
      source: 'plan',
      visibility_status: 'pending'
    )
    expect(latest.geography.name).to eq('Poland')
    expect(latest.sector.name).to eq('Electricity Utilities')
    expect(latest.scopes_list).to include('Scope1')
    expect(latest.scopes.size).to eq(1)
    expect(latest.legislations.size).to eq(1)
    expect(latest.legislation_ids).to include(law.id)
  end

  it 'imports CSV files with CP Benchmarks data' do
    expect_data_upload_results(
      CP::Benchmark,
      cp_benchmarks_csv,
      {new_records: 6, not_changed_records: 0, rows: 6, updated_records: 0}
    )
    # subsequent import should not create or update any record
    expect_data_upload_results(
      CP::Benchmark,
      cp_benchmarks_csv,
      {new_records: 0, not_changed_records: 6, rows: 6, updated_records: 0}
    )
  end

  it 'imports CSV files with Company CP Assessments data' do
    acme_company = create(:company, name: 'ACME', id: 1000)
    acme_materials = create(:company, name: 'ACME Materials', id: 2000)

    expect_data_upload_results(
      CP::Assessment,
      company_cp_assessments_csv,
      {new_records: 2, not_changed_records: 0, rows: 2, updated_records: 0},
      custom_uploader: 'CompanyCPAssessments'
    )
    # subsequent import should not create or update any record
    expect_data_upload_results(
      CP::Assessment,
      company_cp_assessments_csv,
      {new_records: 0, not_changed_records: 2, rows: 2, updated_records: 0},
      custom_uploader: 'CompanyCPAssessments'
    )

    assessment = acme_company.cp_assessments.last
    assessment2 = acme_materials.cp_assessments.last

    expect(assessment.assessment_date).to eq(Date.parse('2019-01-04'))
    expect(assessment.publication_date).to eq(DateTime.strptime('2019-02', '%Y-%m').to_date)
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
    expect(assessment.cp_alignment_2050).to eq('No or unsuitable disclosure')
    expect(assessment.cp_alignment_2025).to eq('Paris Pledges')
    expect(assessment.cp_alignment_2035).to eq('National Pledges')
    expect(assessment.cp_regional_alignment_2025).to eq('1.5 Degrees')
    expect(assessment.cp_regional_alignment_2035).to eq('2 Degrees')
    expect(assessment.cp_regional_alignment_2050).to eq('International Pledges')
    expect(assessment2.cp_alignment_2050).to eq('Not Aligned')
  end

  it 'imports CSV files with Bank CP Assessments data' do
    diamond_bank = create(:bank, name: 'Diamond Corporation')
    bastion_bank = create(:bank, name: 'Bastion Banks Inc.')

    expect_data_upload_results(
      CP::Assessment,
      bank_cp_assessments_csv,
      {new_records: 15, not_changed_records: 0, rows: 15, updated_records: 0},
      custom_uploader: 'BankCPAssessments'
    )
    # subsequent import should not create or update any record
    expect_data_upload_results(
      CP::Assessment,
      bank_cp_assessments_csv,
      {new_records: 0, not_changed_records: 15, rows: 15, updated_records: 0},
      custom_uploader: 'BankCPAssessments'
    )

    assessment = diamond_bank.cp_assessments.last
    assessment2 = bastion_bank.cp_assessments.last

    expect(assessment.assessment_date).to eq(Date.parse('12/6/2023'))
    expect(assessment.publication_date).to eq(DateTime.strptime('2023-07', '%Y-%m').to_date)
    expect(assessment.last_reported_year).to eq(2020)
    expect(assessment.emissions).to eq(
      (2019..2050).each_with_object({}).with_index { |(v, result), i| result[v.to_s] = 100 - i }
    )
    expect(assessment.cp_alignment_2050).to eq('No or unsuitable disclosure')
    expect(assessment.cp_alignment_2027).to eq('National Pledges')
    expect(assessment.cp_alignment_2035).to eq('Not Aligned')
    expect(assessment.cp_regional_alignment_2027).to eq('2 Degrees')
    expect(assessment.cp_regional_alignment_2035).to eq('2 Degrees')
    expect(assessment.cp_regional_alignment_2050).to eq('2 Degrees')
    expect(assessment2.cp_alignment_2050).to eq('Not Aligned')
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
    expect(assessment.methodology_version).to eq(1)
    expect(assessment.assessment_date).to eq(Date.parse('2018-01-25'))
    expect(assessment.questions[0].question).to eq('Question one, level 0?')
    expect(assessment.questions[0].level).to eq('0')
    expect(assessment.questions[0].answer).to eq('Yes')
    expect(assessment.questions[1].question).to eq('Question two, level 1?')
    expect(assessment.questions[1].level).to eq('1')
    expect(assessment.questions[1].answer).to eq('Yes')
  end

  it 'imports CSV files with Banks data' do
    create(:bank, name: 'Edge Bank Inc.')

    expect_data_upload_results(
      Bank,
      banks_csv,
      new_records: 3, not_changed_records: 0, rows: 4, updated_records: 1
    )

    bank = Bank.find_by(name: 'Edge Bank Inc.')
    expect(bank.geography.iso).to eq('GBR')
    expect(bank.latest_information).to eq('Another example of latest information')
    expect(bank.sedol).to eq('304323')
    expect(bank.isin).to eq('GB34343243')
    expect(bank.market_cap_group).to eq('large')
  end

  it 'imports CSV files with Bank Assessment Indicators data' do
    create(:bank_assessment_indicator, indicator_type: 'area', number: '1', text: 'Old Commitment')

    expect_data_upload_results(
      BankAssessmentIndicator,
      bank_assessment_indicators_csv,
      new_records: 20, not_changed_records: 0, rows: 21, updated_records: 1
    )

    changed = BankAssessmentIndicator.find_by(number: '1')
    expect(changed.text).to eq('Commitment')

    expect(BankAssessmentIndicator.area.count).to eq(2)
    expect(BankAssessmentIndicator.indicator.count).to eq(3)
    expect(BankAssessmentIndicator.sub_indicator.count).to eq(16)
    expect(BankAssessmentIndicator.sub_indicator.find_by(number: '2.2.b').text)
      .to eq("Do the targets cover the bank's material financing activities in at least one high-risk sector?")
  end

  it 'imports CSV files with Bank Assessment data' do
    create(:bank, name: 'Edge Bank Inc.')
    create(:bank, name: 'New National Bank System')

    # I don't have time, import indicators again
    expect_data_upload_results(
      BankAssessmentIndicator,
      bank_assessment_indicators_csv,
      new_records: 21, not_changed_records: 0, rows: 21, updated_records: 0
    )

    expect_data_upload_results(
      BankAssessment,
      bank_assessments_csv,
      new_records: 2, not_changed_records: 0, rows: 2, updated_records: 0
    )

    assessment = Bank.find_by(name: 'Edge Bank Inc.').assessments.last
    expect(assessment.assessment_date).to eq(Date.parse('2022-02-25'))
    expect(assessment.results_by_indicator_type['area'].first.percentage).to eq(25.0)
    expect(assessment.results_by_indicator_type['area'].second.percentage).to eq(0.0)
    expect(assessment.results_by_indicator_type['indicator'].first.percentage).to eq(25.0)
    expect(assessment.results_by_indicator_type['sub_indicator'].first.answer).to eq('Yes')
  end

  it 'import CSV file with Geographies data' do
    create(:political_group, name: 'OECD')
    create(:political_group, name: 'G20')
    create(:political_group, name: 'G77')
    create(:political_group, name: 'LDC')

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

  def expect_data_upload_results(uploaded_resource_klass, csv, expected_details, expected_success: true, custom_uploader: nil)
    uploader_name = custom_uploader || uploaded_resource_klass.name.tr('::', '').pluralize
    command = Command::CSVDataUpload.new(uploader: uploader_name, file: csv)

    expect do
      expect(command).to be_valid
      expect(command.call).to(
        eq(expected_success),
        %(
          Expected import command to #{expected_success ? 'succeed' : 'fail'}, but it did not.
          error message: #{command.full_error_messages}
        )
      )
      expect(command.details.symbolize_keys).to eq(expected_details)
    end.to change(uploaded_resource_klass, :count).by(expected_details[:new_records])

    command
  end

  def expect_changes(model, expect_to_change, expect_not_to_change)
    expectations = [
      *expect_to_change.map { |attr| change(model, attr) },
      *expect_not_to_change.map { |attr| not_change(model, attr) }
    ]

    model.reload

    expect do
      yield if block_given?
    end.to expectations.reduce(&:&)
  end

  def fixture_file(filename, content: nil, add_bom: false)
    file_path = "#{Rails.root}/spec/support/fixtures/files/#{filename}"

    if content.present?
      file_path = "#{Rails.root}/tmp/#{filename}"
      File.open(file_path, 'w:UTF-8') do |f|
        f.write("\xEF\xBB\xBF") if add_bom
        f.write(content)
      end
    end

    Rack::Test::UploadedFile.new(
      file_path,
      'text/csv'
    )
  end
end
