class DataDownloadMailer < ApplicationMailer
  def send_download_file_info_email(data)
    @data = data
    mail(to: 'tpi@lse.ac.uk', subject: 'TPI data has been downloaded')
  end
end
