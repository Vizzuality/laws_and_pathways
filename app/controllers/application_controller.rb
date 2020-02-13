class ApplicationController < ActionController::Base
  before_action :set_current_user

  private

  def current_user
    current_admin_user
  end

  def set_current_user
    ::Current.admin_user = current_admin_user
    @current_user = current_admin_user
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html do
        if current_user.present?
          redirect_to admin_root_url, notice: exception.message
        else
          redirect_to root_url, notice: exception.message
        end
      end
      format.js { head :forbidden, content_type: 'text/html' }
    end
  end
end
