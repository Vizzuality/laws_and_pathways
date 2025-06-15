class DataDownloadMailer < ApplicationMailer
  def send_download_file_info_email(data, recipient = 'tpi@lse.ac.uk', subject = 'TPI data has been downloaded')
    @data = data
    mail(to: recipient, subject: subject)
  end
end
