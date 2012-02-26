class ApplicationController < ActionController::Base
  before_filter :authorize
  protect_from_forgery

  protected
  def authorize
    unless User.find_by_id(session[:user_id])
      session[:request_uri] = request.url
      flash[:notice] = "Please login to continue"
      redirect_to login_url
    end
  end
end
