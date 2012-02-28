class SessionsController < ApplicationController
skip_before_filter :authorize

  def new
  end

  def create
    session[:user_id] = nil
    if request.post?
       user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.id
        uri = session[:request_uri]
        session[:request_uri] = nil
        redirect_to (uri || profile_url)
      else
        flash.now[:notice] = "Incorrect Username/Password"
        redirect_to login_url
      end
    end
  end


  def destroy
    session[:user_id] = nil
    flash[:notice] = "You have been logged out"
    redirect_to login_url
  end

end
