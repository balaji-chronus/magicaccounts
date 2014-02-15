class GroupsController < ApplicationController
  def index
    # Get all user's groups
    @groups = current_user.user_groups.page(params[:page]).per_page(10)
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.find_by_id(params[:id])
      session[:original_uri] = request.url
    @balances = Transaction.user_balance(@group).collect do |entry| 
      { 
        :user_id => entry.user_id, 
        :balance => entry.balance.abs.to_s, 
        :transaction_count => entry.transactions,
        :display_class => entry.balance > 0 ? "positive" : "negative"
      }
    end
    respond_to do |format|
      if true
        format.html # show.html.erb
        format.js
        format.json { render json: @group }
      else
        flash[:error] = "Group was not found"
        format.html { redirect_to action: "index" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new    

    @group.users << (current_user)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find_by_id(params[:id])

    respond_to do |format|
      if Group.find_all_by_user_id(current_user).include?(@group)
        format.html # edit.html.erb
        format.json { render json: @group }
      else
        flash[:error] = "Group was not found"
        format.html { redirect_to action: "index" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])
    respond_to do |format|
      if @group.save          
        format.html { redirect_to groups_path, notice: "Group '#{@group.name}' was successfully created." }
        format.json { render json: @group, status: :created, location: @group }
      else
        flash[:error] = "Sorry, your group was not created. #{@group.errors.full_messages.to_sentence}"
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find_by_id(params[:id])
    
    respond_to do |format|
      if Group.find_all_by_user_id(current_user).include?(@group)
        if @group.update_attributes(params[:group])
          format.html { redirect_to groups_path, notice: "Group '#{@group.name}' was successfully updated." }
          format.json { head :ok }
        else
          format.html { render action: "edit" }
          format.json { render json: @group.errors, status: :unprocessable_entity }
        end
      else
        flash[:error] = "Group was not found"
        format.html { redirect_to action: "index" }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find_by_id(params[:id])
    if Group.find_all_by_user_id(current_user).include?(@group)
      flash[:notice] = "Group #{@group.name} was successfully removed"
      @group.destroy
    else
      flash[:error] = "Group was not found"      
    end
    
    respond_to do |format|      
      format.html { redirect_to groups_url }
      format.json { head :ok }
    end
  end

  def adduser
    @group = Group.find_by_code(params[:code])    
    respond_to do |format|
      if @group
        if @group.users.include?(current_user)
            format.html { redirect_to profile_url, notice: "You are already part of '#{@group.name}'" }
            format.json { render json: @group.errors, status: :unprocessable_entity }
        else
          @group.users << (current_user)
          if @group.save
            format.html { redirect_to profile_url, notice: "You have been added to '#{@group.name}'" }
            format.json { head :ok }
          else
            flash[:error] = "Cannot complete your request. Unknown Error"
            format.html { redirect_to groups_url }
            format.json { render json: @group.errors, status: :unprocessable_entity }
          end
        end
      else
        flash[:error] = "Cannot complete your request. Attempt to access an Invalid page"
        format.html { redirect_to groups_url }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def sendinvites
    @toemail = params[:emailids]
    @group = Group.find_by_id(params[:groupid].to_i)
    error_msg = []
    @toemail.split(',').each do |email|
      begin
        if email =~ /[0-9]*/ 
          email = Contact.where(:id => email.to_i).first.try(:email) || email
        end
        if email && email != "" && email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
          if handle_add_group_user(email)
            MagicMailer.group_invite(@group,email).deliver
          else
            error_msg << email
          end
        else
          error_msg << email
        end
      rescue Exception
        flash.now[:error] = "Error sending invites"
      end
    end
      if error_msg.empty?
        flash[:notice] = "Invites sent successfully"
      else
        flash[:error] = "Invitation(s) were not sent for " + error_msg.join(',')
      end
    respond_to do |format|
      format.html { redirect_to session[:original_uri] + "#profil"}
      format.js { redirect_to session[:original_uri] + "#profil"}
    end
  end

  def handle_add_group_user(email)
    user = User.find_by_email(email)
    if user 
      if @group.users.include?(user)
        return user.invite_status != "registered"
      else
        @group.users << user
        return true
      end
    else
      user = User.new(:name => email.split('@').first, :email => email)
      user.save(:validate => false)
      @group.users << user
      return true
    end
  end

  def autocomplete
    @entries = Group.autocomplete_results(params[:term],current_user,params[:page_limit], params[:page])
    @entries = @entries.collect{|e| {id: e.id || params[:term], avatar: Digest::MD5::hexdigest(e.email) ,text: e.email || params[:term]}}
    render :inline => @entries.to_json
  end

end
