class TestFiles
  include Singleton
  include ActionDispatch::TestProcess
  include ActiveSupport::Testing::FileFixtures

  class << self
    delegate :pdf, to: :instance
  end

  def pdf
    fixture_file_upload(
      Rails.root.join('spec', 'support', 'fixtures', 'files', 'test.pdf'), 'application/pdf'
    )
  end
end
