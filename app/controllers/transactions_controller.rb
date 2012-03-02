class TransactionsController < ApplicationController
  before_filter :initiate_account, :only => [:new, :view]

  # GET /transactions
  # GET /transactions.json
  def index
     @balance = Transaction.balance(session[:user_id])
     if @balance
      @uniqueaccounts = @balance.collect { |b| { :accountid => b.account_id, :groupid => b.group_id}}.inject([]) { |result,h| result << h unless result.include?(h); result }
      @uniquegroups = @balance.collect { |b| {:groupid => b.group_id} }.inject([]) { |result,h| result << h unless result.include?(h); result }
     end
     @hasagroup = get_groups_for_current_user.empty? ? nil : 1
     @hasanaccount = @accounts.empty? ? nil : 1
     
      respond_to do |format|
      format.html
      format.json { render json: @balance }
    end
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.json
  def new    
    if params[:accountid] && @accounts.find {|acc| acc.id == params[:accountid].to_i}
      @transaction.account_id = params[:accountid]
      @defaultaccount = Account.find(params[:accountid]).name
    end    
    
    respond_to do |format|      
        format.html # new.html.erb
        format.json { render json: @transaction }        
    end
  end
  

  # GET /transactions/1/edit
  def edit
    @transaction  = Transaction.find(params[:id])    
    @accountusers = get_userlist_for_current_user
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(params[:transaction])

    respond_to do |format|
      if  @transaction.save
          @comment = @transaction.comments.create( {:activity => " added ", :content => @transaction.remarks, :user_name => User.find(session[:user_id]).name})
          @comment.save
          format.html { redirect_to @transaction, notice: 'Transaction was successfully created.' }
          format.json { render json: @transaction, status: :created, location: @transaction }
          format.js
      else
        format.html { redirect_to transactions_url, alert: "Unknown Error #{params[:transaction]}" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.json
  def update
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
         @comment = @transaction.comments.create( {:activity => " changed ", :content => @transaction.remarks, :user_name => User.find(session[:user_id]).name})
         @comment.save
        format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction = Transaction.find(params[:id])
    @comment = @transaction.comments.create( {:activity => " removed ", :content => @transaction.remarks, :user_name => User.find(session[:user_id]).name})
    @comment.save
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to transactions_url }
      format.json { head :ok }
    end
  end

  def view
    
    @transactions = Transaction.view_transactions(session[:user_id], params[:accountid], params[:page])
    
    respond_to do |format|
      if params[:accountid] && @accounts.find {|acc| acc.id == params[:accountid].to_i}
        @transaction.account_id = params[:accountid]
        @defaultaccount = Account.find(params[:accountid]).name
        format.html 
        format.json { render json: @transactions }        
        format.js { render :content_type => 'text/javascript' }

      else
        format.html {redirect_to transactions_url, error: 'Unknown Account'}
        format.html { render }
      end
    end
  end

  private
  def initiate_account
      @disableaccount = action_name == 'view'
      @transaction = Transaction.new      
      @accountusers = get_userlist_for_current_user
  end
  
end
