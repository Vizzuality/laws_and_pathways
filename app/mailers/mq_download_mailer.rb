class MQDownloadMailer < ApplicationMailer
  MQ_INFO_RECIPIENT = 'tpi.centre.management.quality@lse.ac.uk'.freeze
  LSEG_RECIPIENT = 'tpimqaccess@lseg.com'.freeze

  def permitted_use_email(user_email:, download_url:)
    @download_url = download_url
    mail(to: user_email, subject: 'TPI Management Quality Data – Download Link')
  end

  def exempted_use_email(user_email:, download_url:)
    @download_url = download_url
    mail(to: user_email, subject: 'TPI Management Quality Data – Download Link')
  end

  def authorisation_required_email(user_email:)
    mail(to: user_email, subject: 'TPI Management Quality Data – Access Request Received')
  end

  def lseg_notification_email(form_data:)
    @data = form_data
    mail(to: LSEG_RECIPIENT, subject: 'MQ Data Access Request – Uses subject to Authorisation and License')
  end

  def info_email(form_data:, scenario:)
    @data = form_data
    @scenario = scenario
    mail(to: MQ_INFO_RECIPIENT, subject: 'Management Quality data access request')
  end
end

