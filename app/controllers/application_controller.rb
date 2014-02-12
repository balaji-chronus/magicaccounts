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
      @master_balance = TransactionsUser.where("user_id = ?", current_user.id).select("sum(amount_paid) investments, sum(amount) expenses, (sum(amount_paid) - sum(amount)) master_balance").collect do |balance|
        {
          :investments => balance.investments || 0,
          :expenses => balance.expenses || 0,
          :master_balance => balance.master_balance || 0
        }
      end.first
    end
  end

  def set_search_params(params={})
    session[:friends] = params[:friends]
    session[:groups] = params[:groups]
    session[:start] = params[:start] == DEFAULT_START_DATE ? "" : params[:start]
    session[:end] = params[:end] == DEFAULT_END_DATE ? "" : params[:end]
    session[:expense_search_query] = params[:expense_search_query]
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
