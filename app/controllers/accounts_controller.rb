class AccountsController < ApplicationController
  # GET /accounts
  # GET /accounts.json
  def index
    @ownedaccounts = get_user_owned_accounts

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ownedaccounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    @account = Account.find(params[:id])

    respond_to do |format|
    if Account.find_all_by_user_id(session[:user_id]).include?(@account)
      format.html # show.html.erb
      format.json { render json: @account }
    else
      format.html { render action: "index" }
      format.json { render json: @account.errors, status: :unprocessable_entity }
    end
    end
  end

  # GET /accounts/new
  # GET /accounts/new.json
  def new
    @account = Account.new
    @usergroups = get_groups_for_current_user
    if params[:groupid] && @usergroups.find {|grp| grp.id == params[:groupid].to_i}
      @account.group_id = params[:groupid]
      @defaultgroup = Group.find(params[:groupid]).name
    end    

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
    respond_to do |format|
      if Account.find_all_by_user_id(session[:user_id]).include?(@account)
        @usergroups = get_groups_for_current_user
        format.html # edit.html.erb
        format.json { render json: @account }
      else
        format.html { render action: "index" }
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
          @comment = @account.comments.create( {:activity => " added ", :content => @account.name, :user_name => User.find(session[:user_id]).name})
          @comment.save
        format.html { redirect_to @account, notice: 'Account was successfully created.' }
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
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
          @comment = @account.comments.create( {:activity => " changed ", :content => @account.name, :user_name => User.find(session[:user_id]).name})
          @comment.save
        format.html { redirect_to @account, notice: "Account was successfully updated" }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account = Account.find(params[:id])
    if Account.find_all_by_user_id(session[:user_id]).include?(@account)
      @comment = @account.comments.create( {:activity => " removed ", :content => @account.name, :user_name => User.find(session[:user_id]).name})
      @comment.save
      @account.destroy
    end
    respond_to do |format|      
        format.html { redirect_to accounts_url }
        format.json { head :ok }      
    end
  end
end
