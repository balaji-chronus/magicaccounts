class TransactionsController < ApplicationController
  before_filter :initiate_transaction, :only => [:index]

  # GET /transactions
  # GET /transactions.json
  def index
    @transactions = Transaction.view_transactions(current_user, params)
    transaction_categories = Transaction::CATEGORIES.select{|cat| cat}
    @transaction_categories = transaction_categories.push(["All", "all"])

    respond_to do |format|
      @defaultgroup = @groups.find_by_id(params[:groupid].to_i)
      if @defaultgroup.present?
        @transaction.group_id = params[:groupid]
        @groupusers = @defaultgroup.users
        @groupusers.each { |user| @transaction.transactions_users.build({:user => User.find_by_id(user.id)})}
        format.html
        format.js { render :content_type => 'text/javascript' }
      else
        flash[:error] = 'You cannot access this Group or Group doesnot exists'
        format.html { redirect_to profile_url }
        format.html { render }
      end
    end
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    @transaction = Transaction.find_by_id(params[:id])
    authorize! :show, @transaction
    respond_to do |format|
      # Allow the user to see only the transactions that are from his group
      if @groups.find_by_id(@transaction.group.id)
        format.html # show.html.erb
      else
        flash[:error] = "Transaction was not found"
        format.html { redirect_to action: "index" }
      end
    end
  end

  # GET /transactions/1/edit
  def edit
    @transaction  = Transaction.find_by_id(params[:id])
    authorize! :change, @transaction
    respond_to do |format|
      if @transaction.present?
        @defaultgroup = @transaction.group        
          @groupusers = @transaction.group.users
          (User.find_all_by_id(@groupusers.collect(&:id)) - @transaction.transactions_users.collect(&:user)).each do |user|
            @transaction.transactions_users.build({:user => user})
          end
          format.html        
      else
        flash[:error] = "Transaction was not found"
        format.html { redirect_to action: "index" }
      end
    end
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(params[:transaction])
    
    respond_to do |format|
      if @transaction.user == current_user
        if @transaction.save
          @comment = @transaction.comments.create( {:activity => " added ", :content => @transaction.remarks, :user_id => current_user.id, :group_id => @transaction.group.id})
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
      else
        flash.now[:error] = "Investor is not valid"
      end      
      format.js
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.json
  def update
    @transaction = Transaction.find_by_id(params[:id])
    authorize! :change, @transaction
    @transaction.users = User.find(params[:user_ids]) if params[:user_ids]
    respond_to do |format|
      if @transaction.present?
        if @transaction.update_attributes(params[:transaction])
          @comment = @transaction.comments.create( {:activity => " changed ", :content => @transaction.remarks, :user_id => current_user.id, :group_id => @transaction.group.id})
          @comment.save
          format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
        else
          format.html { render action: "edit" }
        end
      else
        flash[:error] = "Transaction was not found"
        format.html { redirect_to action: "index" }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction = Transaction.find_by_id(params[:id])
    authorize! :change, @transaction
    if @transaction.present?
      @comment = @transaction.comments.create( {:activity => " removed ", :content => @transaction.remarks, :user_id => current_user.id, :group_id => @transaction.group.id})
      @comment.save
      flash[:notice] = "Transaction was succesfully removed"
      @transaction.destroy
    else
      flash[:error] = "Transaction was not found"
    end

    respond_to do |format|
      format.html { redirect_to profile_path }
    end
  end

  def user_profile
    @usergroups = current_user.user_groups || []
    @balance = Transaction.user_balance_for(@usergroups.collect(&:id))
    respond_to do |format|
      format.html
    end
  end

  def get_group_balance
    @group = Group.find_by_id(params[:group_id])
    authorize! :view, @group
    @user_group_balance = Transaction.user_balance_for(@group) if @group.present?
  end

  private
  def initiate_transaction
    @transaction = Transaction.new
    @transaction.user = current_user
  end
end