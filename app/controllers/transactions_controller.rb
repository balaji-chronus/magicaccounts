class TransactionsController < ApplicationController
  before_filter :initiate_transaction, :only => [:index]

  # GET /transactions
  # GET /transactions.json
  def index
    options = {}
    options[:expense_search_query] = params[:expense_search_query] || ""
    options[:friends] = (params[:friends_list] || "").split(",")
    options[:groups] = (params[:groups_list] || "").split(",")
    options[:start] = params[:start].blank? ? DEFAULT_START_DATE : params[:start] 
    options[:end] = params[:end].blank? ? DEFAULT_END_DATE : params[:end] 
    options[:user_id] = current_user.id
    @transactions = Transaction.search_transactions(options).paginate(:page => (params[:page] || 1), :per_page => 10)
    set_search_params(options)
  end

  def new
    @transaction = Transaction.new
    
    @defaultgroup = @groups.find_by_id(params[:groupid].to_i)
    if @defaultgroup.present? && current_user.can?(:view, @defaultgroup)
      @transaction.group_id = params[:groupid]
      @groupusers = @defaultgroup.users
      @groupusers.each { |user| @transaction.transactions_users.build({:user => User.find_by_id(user.id)})}
    else
      flash[:error] = 'Invalid Group'
    end
  end

  def user_profile
	tu_array = []
	current_user.transactions_users.each do |tu|
		if tu[:amount_paid] > 0
			tu_array << TransactionsUser.joins("JOIN transactions t ON t.id = transaction_id AND t.actors  LIKE '%|#{tu[:user_id]}|%' AND transactions_users.user_id != #{tu[:user_id]} AND transaction_id = #{tu[:transaction_id]} AND transactions_users.amount != amount_paid").map{|x| {:amount => x.amount, :id => x.user_id}}.reduce
		else
			tu_array.push({ :amount => -tu[:amount], :id => Transaction.find(tu[:transaction_id]).user_id})
		end
	end
	grouped = tu_array.compact.group_by{|x| x[:id]}
	keys = grouped.keys
	@summary = keys.map{|k| [k,grouped[k].reduce(0) {|t,h| t+h[:amount]}]}
	@s_left = @summary.select{|s| s[1] > 0}
	@s_right = @summary.select{|s| s[1] < 0}
	@summary = @s_left.length > @s_right.length ? @s_left.zip(@s_right) : @s_right.zip(@s_left)
  end

  def settle_up
    @transaction = Transaction.new
    @transaction.user = current_user
    @transaction.category = "settlement"
    @transaction.transaction_type = 4
    @transaction.remarks = "Payment"

    @defaultgroup = @groups.find_by_id(params[:groupid].to_i)
    if @defaultgroup.present? && current_user.can?(:view, @defaultgroup)
      @transaction.group_id = params[:groupid]
      @groupusers = @defaultgroup.users
      @groupusers.each { |user| @transaction.transactions_users.build({:user => User.find_by_id(user.id)})}
    else
      flash[:error] = 'Invalid Group'
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
        flash[:error] = "Invalid Expense"
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
        @keywords_query = @transaction.category.split(",").collect(&:strip).collect do |tag|
          {:id => tag, :text => tag, :icon_class => "icon-#{Transaction::CATEGORY_ICON_MAPPING[tag]}"}
        end
        @defaultgroup = @transaction.group
          @groupusers = @transaction.group.users
          (@groupusers - @transaction.transactions_users.collect(&:user)).each do |user|
            @transaction.transactions_users.build({:user => user})
          end
          format.html        
      else
        flash[:error] = "Invalid Expense"
        format.html { redirect_to action: "index" }
      end
    end
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(params[:transaction])

    if @transaction.save
      @comment = @transaction.comments.create( {:activity => " added ", :content => @transaction.remarks, :user_id => current_user.id, :group_id => @transaction.group.id})
      @comment.save
      @transaction.transactions_users.each do |transaction|
        if !(@transaction.user == transaction.user)
          MagicMailer.transaction_notification(@transaction, "Added", transaction.amount, transaction.user).deliver
        end
      end
      flash[:notice] = "Expense was successfully created"
    else
      flash.now[:error] = @transaction.errors.full_messages.compact.uniq.join("<br/>")
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.json
  def update
    @transaction = Transaction.find_by_id(params[:id])
    @show_error = false
    authorize! :change, @transaction
    
    if @transaction.present?
      if @transaction.update_attributes(params[:transaction])
        @comment = @transaction.comments.create( {:activity => " changed ", :content => @transaction.remarks, :user_id => current_user.id, :group_id => @transaction.group.id})
        @comment.save!
        flash[:notice] = 'Expense was successfully updated.'
      else
        flash.now[:error] = @transaction.errors.full_messages.compact.uniq.join("<br/>")
      end
    else
      flash.now[:error] = "Expense was not found"
      @show_error = true
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

  def get_group_balance
    @group = Group.find_by_id(params[:group_id])
    authorize! :view, @group
    @user_group_balance = Transaction.user_balance(@group) if @group.present?
  end

  def autocomplete_category_tags
    entries = Transaction.get_autocomplete_tags(params[:term], params[:page], params[:page_limit], params[:selection])
    @entries_array = entries.collect{|entry| {"icon_class" => "icon-#{Transaction::CATEGORY_ICON_MAPPING[entry]}", "text" => entry.capitalize, "id" => entry }} if entries
    render :inline => @entries_array.to_json
  end

  private
  def initiate_transaction
    @transaction = Transaction.new
    @transaction.user = current_user
  end
end