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
  #   @authentication = Authentication.new(params[:authentication])
#@authentication = true
  #   respond_to do |format|
  #     if @authentication.save
  #       format.html { redirect_to @authentication, notice: 'Authentication was successfully created.' }
  #       format.json { render json: @authentication, status: :created, location: @authentication }
  #     else
  #       format.html { render action: "new" }
  #       format.json { render json: @authentication.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  omniauth = request.env["omniauth.auth"]
  authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
  if authentication
    flash[:notice] = "Signed in successfully."
    user = authentication.user
    session[:user_id] = user.id
        uri = session[:request_uri]
        session[:request_uri] = nil
        redirect_to (uri || profile_url)

          elsif current_user
    current_user.authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'])
    flash[:notice] = "Authentication successful."
    redirect_to authentications_url

  else
    session[:omniauth] = omniauth.except('extra')
    redirect_to new_user_path  

  end
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
