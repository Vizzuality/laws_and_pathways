class ApplicationMailer < ActionMailer::Base
  default from: ENV['SMTP_DEFAULT_FROM']
  layout 'mailer'
end
