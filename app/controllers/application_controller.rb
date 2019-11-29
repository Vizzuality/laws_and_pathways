class ApplicationController < ActionController::Base
  include BaseAuth

  before_action :set_current_user

  private

  def set_current_user
    ::Current.admin_user = current_admin_user
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end
end
