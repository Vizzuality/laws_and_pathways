class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SMTP_DEFAULT_FROM', 'from@example.com')
  layout 'mailer'
end
