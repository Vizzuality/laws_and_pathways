module TestFiles
  module_function

  extend ActionDispatch::TestProcess

  def pdf
    fixture_file_upload(
      Rails.root.join('spec', 'support', 'fixtures', 'files', 'test.pdf'), 'application/pdf'
    )
  end
end
