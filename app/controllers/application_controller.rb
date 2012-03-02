class ApplicationController < ActionController::Base
  before_filter :authorize, :load_activities
  protect_from_forgery

  helper_method :get_transaction_activity_for_current_user

  def get_user_owned_groups
      Group.where('user_id = ?', session[:user_id])
  end

  def get_user_owned_accounts
      Account.where('user_id = ?',  session[:user_id])
  end

  def get_userlist_for_current_user
      User.joins("JOIN groups_users UG ON users.id = UG.user_id").joins("JOIN accounts A ON A.group_id = UG.group_id").where("UG.group_id IN (SELECT DISTINCT group_id FROM groups_users where user_id = ?)",session[:user_id]).select("DISTINCT users.id user_id, users.name user_name")
  end

  def get_groups_for_current_user
      Group.where(" id IN (SELECT DISTINCT group_id FROM groups_users where user_id = ?)",session[:user_id])
  end

  def load_activities  
    @accounts =  Account.joins("JOIN groups G ON accounts.group_id = G.id").where("G.id IN (SELECT DISTINCT group_id FROM groups_users where user_id = ?)",session[:user_id]).select("accounts.*")
    @activitytran = Transaction.where("account_id IN (?) ", @accounts.map {|acc| acc.id}).inject([]) {|result, tran| result << tran.comments unless tran.comments.empty?; result}.sort! {|t1,t2| t2.first.created_at <=> t1.first.created_at}
    @activityacc  = Account.where("id IN (?) ", @accounts.map {|acc| acc.id}).inject([]) {|result, acc| result << acc.comments unless acc.comments.empty?; result}.sort! {|t1,t2| t2.first.created_at <=> t1.first.created_at}
  end

  protected
  def authorize
    unless User.find_by_id(session[:user_id])
      session[:request_uri] = request.url
      flash[:notice] = "Please login to continue"
      redirect_to login_url
    end
  end  
end
