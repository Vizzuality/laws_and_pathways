module CCLOW
  class CCLOWController < ApplicationController
    before_action :authenticate

    layout 'cclow'

    protected

    def add_breadcrumb(title, path)
      @breadcrumb = (@breadcrumb || []).push(Site::Breadcrumb.new(title, path))
    end

    private

    def authenticate
      return if Rails.env.development?

      authenticate_or_request_with_http_basic do |username, password|
        username == Rails.application.credentials.base_auth_user &&
          password == Rails.application.credentials.base_auth_password
      end
    end
  end
end
