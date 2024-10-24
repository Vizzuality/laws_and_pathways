require 'rails_helper'

RSpec.describe DataDownloadMailer, type: :mailer do
  describe 'send_download_file_info_email' do
    let(:data) {
      {
        email: 'test@test.test',
        job_title: 'job_title',
        forename: 'forename',
        surname: 'surname',
        location: 'location',
        organisation: 'organisation',
        purposes: %w[purpose1 purpose2]
      }
    }
    let(:mail) { DataDownloadMailer.send_download_file_info_email data }

    it 'renders the headers' do
      expect(mail.subject).to eq('TPI data has been downloaded')
      expect(mail.to).to eq(['tpi@lse.ac.uk'])
      expect(mail.from).to eq([ENV.fetch('SMTP_DEFAULT_FROM', 'from@example.com')])

      expect(mail.body.encoded).to include('test@test.test')
      expect(mail.body.encoded).to include('job_title')
      expect(mail.body.encoded).to include('forename')
      expect(mail.body.encoded).to include('surname')
      expect(mail.body.encoded).to include('location')
      expect(mail.body.encoded).to include('organisation')
      expect(mail.body.encoded).to include('purpose1')
      expect(mail.body.encoded).to include('purpose2')
    end
  end
end
