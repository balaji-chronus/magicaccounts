class AuthenticationsController < ApplicationController
  # GET /authentications
  # GET /authentications.json
  skip_before_filter :authorize ,:only => [:new,:create]
  def index
    @authentications = Authentication.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @authentications }
    end
  end

  # GET /authentications/1
  # GET /authentications/1.json
  def show
    @authentication = Authentication.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @authentication }
    end
  end

  # GET /authentications/new
  # GET /authentications/new.json
  def new
    @authentication = Authentication.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @authentication }
    end
  end

  # GET /authentications/1/edit
  def edit
    @authentication = Authentication.find(params[:id])
  end

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
        user.save(:validate => false)
        flash[:notice] = "User '#{user.name}' was successfully created."
      else
      user.authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'],:token => omniauth["credentials"]["token"])
      flash[:notice] = "Authentication successful."
      end

    end
    sign_in_and_redirect(user)
  end

  # PUT /authentications/1
  # PUT /authentications/1.json
  def update
    @authentication = Authentication.find(params[:id])

    respond_to do |format|
      if @authentication.update_attributes(params[:authentication])
        format.html { redirect_to @authentication, notice: 'Authentication was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @authentication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authentications/1
  # DELETE /authentications/1.json
  def destroy
    @authentication = Authentication.find(params[:id])
    @authentication.destroy

    respond_to do |format|
      format.html { redirect_to authentications_url }
      format.json { head :no_content }
    end
  end
end
