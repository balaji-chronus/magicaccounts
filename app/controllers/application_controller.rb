class ApplicationController < ActionController::Base
  before_filter :authorize, :load_activities
  protect_from_forgery

  helper_method :current_user
  
  def current_ability
    Ability.new(current_user)
  end

  def load_activities  
    if current_user
      @groups =  current_user.user_groups
      @activitytran = Comment.where(["commentable_type = 'Transaction' AND commentable_id IN (?)", Transaction.get_user_transactions(current_user).collect(&:id)]).order("created_at DESC").limit(3)
    end
  end

  def sign_in_and_redirect(user)
    session[:user_id] = user.id
    uri = session[:request_uri]
    session[:request_uri] = nil
    redirect_to (uri || profile_url)
  end

  rescue_from CanCan::AccessDenied do |exception|
      flash[:error] = "Access denied."
    redirect_to root_url
  end

  protected
  def authorize
    unless current_user
      session[:request_uri] = request.url
      flash[:notice] = "Please login to continue"
      redirect_to login_url
    end
  end

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
