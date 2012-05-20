class TransactionsController < ApplicationController
  before_filter :initiate_account, :only => [:new, :index]

  # GET /transactions
  # GET /transactions.json
  def index
    @filtered_transactions = Transaction.search(params)
    @transactions = Transaction.view_transactions(current_user, @filtered_transactions.collect(&:id))
    transaction_categories = Transaction::CATEGORIES.select{|cat| cat}
    @transaction_categories = transaction_categories.push(["All", "all"])

    respond_to do |format|
      if params[:accountid] && @accounts.find {|acc| acc.id == params[:accountid].to_i}
        @transaction.account_id = params[:accountid]
        @defaultaccount = Account.find_by_id(params[:accountid])
        format.html
        format.json { render json: @transactions }
        format.js { render :content_type => 'text/javascript' }

      else
        flash[:error] = 'You cannot access this Account or Account doesnot exists'
        format.html { redirect_to profile_url }
        format.html { render }
      end
    end
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    @transaction = Transaction.find_by_id(params[:id])

    respond_to do |format|
      # Allow the user to see only the transactions that are from his group
      if @accounts.find {|acc| acc.id == @transaction.account.id.to_i}
        format.html # show.html.erb
        format.json { render json: @transaction }
      else
        flash[:error] = "Transaction was not found"
        format.html { redirect_to action: "index" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /transactions/new
  # GET /transactions/new.json
  def new    
    
    if params[:accountid] && @accounts.find {|acc| acc.id == params[:accountid].to_i}
      @transaction.account_id = params[:accountid]
      @defaultaccount = Account.find_by_id(params[:accountid])
    end    
    
    respond_to do |format|      
      format.html # new.html.erb
      format.json { render json: @transaction }
    end
  end
  

  # GET /transactions/1/edit
  def edit
    @transaction  = Transaction.find_by_id(params[:id])
    @defaultaccount = @transaction.account
    respond_to do |format|
      if @transaction
        if (@transaction.user == current_user || @transaction.users.find_by_id(current_user))
          @accountusers = User.get_userlist_for_current_user(current_user)
          (User.find_all_by_id(@accountusers.collect(&:user_id)) - @transaction.transactions_users.collect(&:user)).each do |user|
            @transaction.transactions_users.build({:user => user})
          end
          format.html
          format.json { render json: @transaction }
        else
          flash[:error] = "You cannot edit this transaction or the transaction was not found"
          format.html { redirect_to action: "index" }
          format.json { render json: @transaction.errors, status: :unprocessable_entity }
        end
      else
        flash[:error] = "You cannot edit this transaction or the transaction was not found"
        format.html { redirect_to action: "index" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(params[:transaction])
    
    respond_to do |format|
      if @transaction.save
        @comment = @transaction.comments.create( {:activity => " added ", :content => @transaction.remarks, :user_id => current_user, :group_id => @transaction.account.group_id})
        @comment.save
        @transaction.transactions_users.each do |transaction|
            if !(@transaction.user == transaction.user)
              MagicMailer.transaction_notification(@transaction, "Added", transaction.amount, transaction.user).deliver
            end
        end
        flash.now[:notice] = "Transaction was successfully created"
      else
        flash.now[:error] = @transaction.errors.full_messages.compact.uniq.join("\n")
      end           
      format.js
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.json
  def update
    @transaction = Transaction.find_by_id(params[:id])
    @transaction.users = User.find(params[:user_ids]) if params[:user_ids]
    respond_to do |format|
      if (@transaction.user == current_user || @transaction.users.find_by_id(current_user))
        if @transaction.update_attributes(params[:transaction])
          @comment = @transaction.comments.create( {:activity => " changed ", :content => @transaction.remarks, :user_id => current_user, :group_id => @transaction.account.group_id})
          @comment.save
          format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
          format.json { head :ok }
        else
          format.html { render action: "edit" }
          format.json { render json: @transaction.errors, status: :unprocessable_entity }
        end
      else
        flash[:error] = "You cannot update this transaction or the transaction was not found"
        format.html { redirect_to action: "index" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction = Transaction.find_by_id(params[:id])
    if (@transaction.user == current_user || @transaction.users.find_by_id(current_user))
      @comment = @transaction.comments.create( {:activity => " removed ", :content => @transaction.remarks, :user_id => current_user, :group_id => @transaction.account.group_id})
      @comment.save
      flash[:notice] = "Transaction was succesfully removed"
      @transaction.destroy
    else
      flash[:error] = "You cannot remove this transaction or the transaction was not found"
    end

    respond_to do |format|
      format.html { redirect_to profile_path }
      format.json { head :ok }
    end
  end

  def user_profile
    @usergroups = Group.get_groups_for_current_user(current_user)
    @balance = Transaction.balance(current_user)
    respond_to do |format|
      format.html
      format.json { render json: @balance }
    end
  end

  private
  def initiate_account
    @transaction = Transaction.new
    @accountusers = User.get_userlist_for_current_user(current_user)
    @accountusers.each { |user| @transaction.transactions_users.build({:user => User.find_by_id(user.user_id)})}
  end
  
end
