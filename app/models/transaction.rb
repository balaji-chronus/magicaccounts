class Transaction < ActiveRecord::Base

  CATEGORIES = [
    ["General", 'general'],
    ["Food", 'food'],
    ["Fuel", "fuel"],
    ["Household", "household"],
    ["Rent", "rent"],
    ["Electricity", "electricity"],
    ["Dues", "dues"],
    ["Outing", "outing"],
    ["Liqour", "liqour"],
    ["Maintainance", "maintainance"],
    ["Entertainment", "entertainment"],
    ["Footwear", "footwear"],
    ["Settlement", "settlement"],
    ["Telephone", "telephone"],
    ["Miscellaneous", "miscellaneous"]
  ]

  CATEGORY_ICON_MAPPING = {
    "general" => "exclamation",
    "food" => "food",
    "fuel" => "tint",
    "household" => "home",
    "electricity" => "lightbulb",
    "dues" => "money",
    "party" => "glass",
    "maintainance" => "wrench",
    "entertainment" => "ticket",
    "settlement" => "money",
    "telephone" => "phone-sign",
    "miscellaneous" => "cloud",
    "games" => "gamepad",
    "coffee" => "coffee",
    "sports" => "dribbble",
    "loan" => "money",
    "insurance" => "money",
    "movies" => "film",
    "internet" => "signal",
    "medical" => "ambulance",
    "shopping" => "shopping-cart",
    "travel" => "plane",
    "transportation" => "truck",
    "trash" => "trash",
    "music" => "music",
    "rent" => "building",
    "stationary" => "pushpin",
    "emi" => "calendar",
    "groceries" => "shopping-cart",
    "outing" => 'sun'
  }

  TRANSACTION_TYPES = ["", "Split Equally", "Split by Exact Amount", "Record a personal transaction", "Settlement"]

  acts_as_taggable

  validates :txndate, :remarks, :presence => {:message => "cannot be blank"}
  validates :user_id, :presence => {:message => "/Expense spender must be selected"}
  validates :transactions_users, :presence => {:message => "- one or more expense benefactors should have an amount more than zero"}
  validate  :transaction_validations

  belongs_to  :user
  belongs_to  :entered_user, :foreign_key => "enteredby", :class_name => "User" 
  belongs_to  :group
  has_many    :comments, :as => :commentable
  has_many    :users, :through => :transactions_users
  has_many    :transactions_users, :dependent => :destroy
  accepts_nested_attributes_for :transactions_users, :reject_if => lambda { |a| a[:amount].blank? && a[:amount_paid].blank? }, :allow_destroy => true  

  before_save  :set_actors
  

  def self.search_transactions(options = {})
    # Get rid of this LIKE query
    transactions = Transaction.where("actors like '%|#{options[:user_id]}|%'").order("txndate desc").includes(:transactions_users)
    transactions = transactions.where("txndate between ? AND ?", options[:start], options[:end])
    transactions = transactions.select{|transaction| (transaction.transactions_users.collect(&:user_id) & options[:friends].collect(&:to_i)).count > 0} if options[:friends].present?
    transactions = transactions.select{|transaction| (transaction.tag_list & options[:groups]).count > 0} if options[:groups].present?
    transactions = transactions.select{|transaction| (/#{options[:expense_search_query]}/ =~ transaction.remarks.downcase).present? } if options[:expense_search_query].present?
    return transactions
  end

  def self.view_transactions(user, params)
    Transaction.paginate_by_sql(['
      SELECT 	id,
              amount,
              CASE 	WHEN amount - net_amount = 0 THEN CONCAT("Your Expenditure is Rs. ", ROUND(amount))
                WHEN type = "investor" THEN CONCAT("Your Investment is Rs. ", ROUND(amount - net_amount))
                WHEN type = "beneficiary" THEN CONCAT("Your Expenditure is Rs. ", ROUND(net_amount))
              END	details,
              remarks,
              txndate
      FROM   	( SELECT  A.id,
                        CASE  WHEN A.user_id = ? THEN "investor"
                              WHEN COUNT(CASE WHEN B.user_id = ? THEN 1 END) >= 1 THEN "beneficiary"
                              ELSE  "none" END type,
                        SUM(CASE WHEN B.user_id = ? THEN B.amount ELSE 0 END) net_amount,
                        SUM(B.amount) amount, 
                        A.remarks,
                        A.txndate,
                        IFNULL(A.updated_at, A.created_at) created_at
                FROM    transactions A JOIN transactions_users B
                ON      A.id = B.transaction_id
                WHERE   txndate between ? AND ? ' +
                ((params[:group_id].present?) ? "AND group_id = #{params[:group_id]}" : " ") +
                ((params[:query].present?) ? "AND LOWER(remarks) LIKE '%#{params[:query].downcase}%'" : " ") +
                'GROUP   BY A.id )tmp
      WHERE     type <> "none"
      ORDER     BY txndate DESC, created_at DESC ', user.id, 
                                                    user.id, 
                                                    user.id,
                                                    (params[:transaction_start_date].blank? ? DateTime.new(1000,1,1) : params[:transaction_start_date]), 
                                                    (params[:transaction_end_date].blank? ? DateTime.new(3000,1,1) : params[:transaction_end_date])], :page => params[:page] || 1, :per_page => 10)
  end

  def self.spend_by(parameter, user, start_time, end_time)
    Transaction.find_by_sql([" SELECT	#{parameter}, SUM(ROUND(amount)) spend, COUNT(DISTINCT id) txn_count
                            FROM	transactions_beneficiaries
                            WHERE	((user_id <> ? AND	beneficiary_id = ?) OR (user_id = ? AND	beneficiary_id = ?))
                            AND	category != 'settlement'
                            #{start_time.blank? ? "" : " AND txndate BETWEEN '#{start_time}' AND '#{end_time}' "}
                            GROUP	BY #{parameter}", user, user, user, user])
  end

  def self.get_user_transactions(user)
    Transaction.joins("JOIN transactions_users TU ON transactions.id = TU.transaction_id").where("TU.user_id = ?", user.id)
  end

  def self.user_balance(group)
    Transaction.joins("JOIN transactions_users tu ON transactions.id = tu.transaction_id AND transactions.group_id = #{group.id}").group("tu.user_id").order("(SUM(amount_paid) - SUM(tu.amount)) DESC").select("tu.user_id, (SUM(amount_paid) - SUM(tu.amount)) balance, COUNT(distinct transaction_id) transactions")
  end

  def self.get_autocomplete_tags(term, page = 1, per_page = 10, selection = [])
    tags = (Transaction.tag_counts_on(:tags).collect(&:name) + CATEGORY_ICON_MAPPING.keys).uniq.sort
    (tags = tags.select{|tag| (/#{term.downcase}/ =~ tag.downcase).present?}) if term.present?
    tags = tags.select{|tag| !selection.include?(tag)} if selection.present?
    return (tags || []).paginate(:page => page, :per_page => per_page)
  end

  def expense_users
    self.transactions_users.collect(&:user).push(self.user)
  end

  def tag_list
    (self.category || "").split(",").collect(&:strip)
  end

  private
  
  def transaction_validations
    if (self.amount || 0.00) <= 0
      errors.add(:expense, " amount must be greater than zero")
    end

    players = self.expense_users.collect(&:id).compact.uniq || []
    if players.count > 0 && (players - Group.find_by_id(self.group_id).users.collect(&:id)).count > 0
      errors.add(:some, " of the users in the expense don't belong to this group")
    end

    if (self.amount || 0.00 > 0) && self.amount != self.transactions_users.collect(&:amount).compact.sum
      errors.add(:expense, " benefactor amounts don't add up with the expense amount")
    end

    if players.count > 0 && !players.include?(self.enteredby.to_i)
      errors.add(:you, " cannot add this expense. You should be part of this expense")
    end
  end

  def set_actors
    players = self.transactions_users.collect(&:user_id).push(self.user_id).uniq
    self.actors = "|#{players.join('|')}|"
  end
end


