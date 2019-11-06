module BaseAuth
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
  end

  private

  def authenticate
    return if Rails.env.development? || Rails.env.test?

    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials.base_auth_user &&
        password == Rails.application.credentials.base_auth_password
    end
  end
end
