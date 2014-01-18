class AuthenticationsController < ApplicationController
  # GET /authentications
  # GET /authentications.json
  skip_before_filter :authorize 


  # POST /authentications
  # POST /authentications.json
  def create
    if current_user
      flash[:notice] = "You are already signed in"
      redirect_to profile_url
      return 
    end
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    
    if authentication
      authentication.update_attributes(:token => omniauth["credentials"]["token"])
      user = authentication.user
      flash[:notice] = "Signed in successfully."
    else
      user = User.find_by_email(omniauth['info']['email'])
      
      if !user 
        user = User.new
        user.name = omniauth['info']['name']
        user.email = omniauth['info']['email']
        user.user_type = "User"
        user.authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'],:token => omniauth["credentials"]["token"])
        flash[:notice] = "User '#{user.name}' was successfully created."
      else
      user.authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'],:token => omniauth["credentials"]["token"])
      flash[:notice] = "Authentication successful."
      end
            user.invite_status = User::INVITE_STATUS::REGISTERED
            user.save(:validate => false)

    end
    sign_in_and_redirect(user)
  end

 
end