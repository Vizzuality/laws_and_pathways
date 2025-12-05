class AddCPMethodologyPublicationIdToBanksContent < ActiveRecord::Migration[6.1]
  def up
    bank_page = TPIPage.find_by(slug: 'banks-content')
    return unless bank_page

    bank_page.contents.create!(
      title: 'CP Methodology Publication ID',
      code: 'cp_methodology_publication_id',
      text: '',
      content_type: 'regular'
    )
  end

  def down
    bank_page = TPIPage.find_by(slug: 'banks-content')
    return unless bank_page

    bank_page.contents.find_by(code: 'cp_methodology_publication_id')&.destroy
  end
end
