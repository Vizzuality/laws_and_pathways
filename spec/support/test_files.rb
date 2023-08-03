class TestFiles
  include Singleton
  include ActionDispatch::TestProcess
  include ActiveSupport::Testing::FileFixtures
  include ActionDispatch::TestProcess::FixtureFile

  class << self
    delegate :pdf, :png, :csv, to: :instance
  end

  def png
    fixture_file_upload(
      Rails.root.join('spec', 'support', 'fixtures', 'files', 'test.png'), 'image/png'
    )
  end

  def pdf
    fixture_file_upload(
      Rails.root.join('spec', 'support', 'fixtures', 'files', 'test.pdf'), 'application/pdf'
    )
  end

  def csv
    fixture_file_upload(
      Rails.root.join('spec', 'support', 'fixtures', 'files', 'companies.csv'), 'text/csv'
    )
  end
end
