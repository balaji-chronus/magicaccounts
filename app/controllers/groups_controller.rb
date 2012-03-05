class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.json
  def index
    @groups = get_user_owned_groups
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.find_by_id(params[:id])
    respond_to do |format|
      if Group.find_all_by_user_id(session[:user_id]).include?(@group)
        format.html # show.html.erb
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

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find_by_id(params[:id])

    respond_to do |format|
      if Group.find_all_by_user_id(session[:user_id]).include?(@group)
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
    @group.users << (User.find_by_id(session[:user_id]) if session[:user_id]) if @group
    respond_to do |format|
      if @group.save
          @comment = @group.comments.create( {:activity => "create", :content => @group.name, :user_name => User.find_by_id(session[:user_id]).name})
          @comment.save
        format.html { redirect_to groups_path, notice: "Group '#{@group.name}' was successfully created." }
        format.json { render json: @group, status: :created, location: @group }
      else
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
      if Group.find_all_by_user_id(session[:user_id]).include?(@group)
          if @group.update_attributes(params[:group])
              @comment = @group.comments.create( {:activity => "change", :content => @group.name, :user_name => User.find_by_id(session[:user_id]).name})
              @comment.save
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
    if Group.find_all_by_user_id(session[:user_id]).include?(@group)
        @comment = @group.comments.create( {:activity => "remove", :content => @group.name, :user_name => User.find_by_id(session[:user_id]).name})
        @comment.save
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
        @group.users << (User.find_by_id(session[:user_id]) if session[:user_id]) 
        if @group.save
          format.html { redirect_to groups_url, notice: "You have been added to '#{@group.name}'" }
          format.json { head :ok }
        else
          flash[:error] = "Cannot complete your request. Unknown Error"
          format.html { redirect_to groups_url }
          format.json { render json: @group.errors, status: :unprocessable_entity }
        end
      else
        flash[:error] = "Cannot complete your request. Attempt to access an Invalid page"
        format.html { redirect_to groups_url }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end
end
