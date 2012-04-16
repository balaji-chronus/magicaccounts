class ApplicationController < ActionController::Base
  before_filter :authorize, :load_activities
  protect_from_forgery

  helper_method :current_user
  
  def current_ability
    Ability.new(current_user)
  end

  def load_activities  
    @accounts =  Account.joins("JOIN groups G ON accounts.group_id = G.id").where("G.id IN (SELECT DISTINCT group_id FROM groups_users where user_id = ?)",current_user).select("accounts.*")
    @activitytran = Comment.where(["commentable_type = 'Transaction' AND group_id IN (?)", Group.get_groups_for_current_user(current_user).map(&:id)]).order("created_at DESC")
    @activityacc = Comment.where(["commentable_type = 'Account' AND group_id IN (?)", Group.get_groups_for_current_user(current_user).map(&:id)]).order("created_at DESC")
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
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
