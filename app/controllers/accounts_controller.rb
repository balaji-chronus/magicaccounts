class AccountsController < ApplicationController
  before_filter :initiate_groups, :only => [:new, :edit, :create, :update]
  # GET /accounts
  # GET /accounts.json
  def index
    @ownedaccounts = Account.get_user_owned_accounts(current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ownedaccounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    @account = Account.find_by_id(params[:id])

    respond_to do |format|
      # Allow the user to see only the accounts that are from one of his groups
      if @accounts.find {|acc| acc.id == @account.id.to_i}
        format.html # show.html.erb
        format.json { render json: @account }
      else
        flash[:error] = "Account was not found"
        format.html { redirect_to action: "index" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /accounts/new
  # GET /accounts/new.json
  def new
    @account = Account.new
    
    if params[:groupid] && @usergroups.find {|grp| grp.id == params[:groupid].to_i}
      @account.group_id = params[:groupid]
      @defaultgroup = Group.find_by_id(params[:groupid]).name
    end    

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find_by_id(params[:id])
    respond_to do |format|
      if Account.find_all_by_user_id(current_user).include?(@account)
        format.html # edit.html.erb
        format.json { render json: @account }
      else
        flash[:error] = "Account was not found"
        format.html { redirect_to action: "index" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if  @account.save
        @comment = @account.comments.create( {:activity => " added ", :content => @account.name, :user_id => current_user, :group_id => @account.group_id})
        @comment.save
        format.html { redirect_to profile_path, notice: "Account #{@account.name} was successfully created." }
        format.json { render json: @account, status: :created, location: @account }
      else
        format.html { render action: "new" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @account = Account.find_by_id(params[:id])

    respond_to do |format|
      if Account.find_all_by_user_id(current_user).include?(@account)
        if @account.update_attributes(params[:account])
          @comment = @account.comments.create( {:activity => " changed ", :content => @account.name, :user_id => current_user, :group_id => @account.group_id})
          @comment.save
          format.html { redirect_to @account, notice: "Account #{@account.name} was successfully updated" }
          format.json { head :ok }
        else
          format.html { render action: "edit" }
          format.json { render json: @account.errors, status: :unprocessable_entity }
        end
      else
        flash[:error] = "Account was not found"
        format.html { redirect_to action: "index" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account = Account.find_by_id(params[:id])
    if Account.find_all_by_user_id(current_user).include?(@account)
      @comment = @account.comments.create( {:activity => " removed ", :content => @account.name, :user_id => current_user, :group_id => @account.group_id})
      @comment.save
      flash[:notice] = "Account #{@account.name} was successfully removed"
      @account.destroy
    else
      flash[:error] = "Account was not found"
    end
    
    respond_to do |format|      
      format.html { redirect_to accounts_url }
      format.json { head :ok }
    end
  end

  private
  def initiate_groups
    @usergroups = Group.get_groups_for_current_user(current_user)
  end
end
