class UsersController < ApplicationController
  skip_before_filter :authorize, :only => [:new, :create,:oauth_failure]
  # GET /users
  # GET /users.json
  def index    
    @users = User.all
    authorize! :index, User

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    authorize! :show, @user    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit    
    @user = User.find(params[:id])
    authorize! :edit, @user
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    user = User.find_by_email(@user.email)
    if user.try(:invite_status) == "not_registered"
          user.update_attributes(params[:user])
          sign_in_and_redirect(user)
    else
    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        MagicMailer.registration_success(@user).deliver
        format.html { redirect_to profile_path, notice: "User '#{@user.name}' was successfully created." }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.js 
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update    
    @user = User.find(params[:id])
    authorize! :edit, @user
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to profile_path, notice: "User '#{@user.name}' was successfully updated." }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    authorize! :destroy, @user
    session[:user_id] = nil
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

  def dashboard
    
  end

  def oauth_failure
    flash[:error] = "Access denied by the user"
    redirect_to login_url 
  end

  def contacts
    @contacts = request.env['omnicontacts.contacts']
    @contacts.each do |contact|
      current_user.contacts << Contact.new(:name => contact[:name], :email => contact[:email])
    end
    flash.now[:notice]="contacts added"
    uri = session[:original_uri]
    session[:original_uri] = nil
    redirect_to uri + "#profile"
  end
 

  def autocomplete_friends
    entries = current_user.autocomplete_users(params[:term], params[:page], params[:page_limit], params[:selection])
    @entries_array = entries.collect{|entry| {"icon_class" => "icon-user", "text" => entry.user_name.capitalize, "id" => entry.user_id }} if entries
    render :inline => @entries_array.to_json
  end
end
