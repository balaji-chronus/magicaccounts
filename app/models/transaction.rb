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
    "general" => "puzzle-piece",
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
    "miscellaneous" => "puzzle-piece",
    "games" => "gamepad",
    "coffee" => "coffee",
    "sports" => "dribble",
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
    "loan-emi" => "calender",
    "groceries" => "shopping-cart"
  }

  TRANSACTION_TYPES = [
    ["Track a Personal Expense","1"],
    ["Group - Split Equally", "2"],
    ["Group - Not Split Equally", "3"]
  ]

  acts_as_taggable

  validates :txndate,   :remarks, :presence => {:message => "Cannot be blank"}
  validates :transactions_users, :presence => true
  validate  :check_group_user_access

  belongs_to  :user
  belongs_to  :entered_user, :foreign_key => "enteredby", :class_name => "User" 
  belongs_to  :group
  has_many    :comments, :as => :commentable
  has_many    :users, :through => :transactions_users
  has_many    :transactions_users, :dependent => :destroy
  accepts_nested_attributes_for :transactions_users, :reject_if => lambda { |a| a[:amount].blank? }, :allow_destroy => true  
  

  def self.search_transactions(options = {})
    # Get rid of this LIKE query
    return Transaction.where("actors like '%|#{options[:user_id]}|%'").order("txndate desc").includes(:transactions_users)
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
    Transaction.joins("JOIN transactions_users TU ON transactions.id = TU.transaction_id").where("transactions.user_id = ? OR TU.user_id = ?", user.id, user.id).order("transactions.txndate DESC, transactions.updated_at DESC")
  end

  def self.user_balance(group)
    Transaction.joins("JOIN transactions_users tu ON transactions.id = tu.transaction_id AND transactions.group_id = #{group.id}").group("tu.user_id").order("(SUM(amount_paid) - SUM(tu.amount)) DESC").select("tu.user_id, (SUM(amount_paid) - SUM(tu.amount)) balance, COUNT(distinct transaction_id) transactions")
  end

  def self.get_autocomplete_tags(term, page = 1, per_page = 10, selection = [])
    tags = Transaction.tag_counts_on(:tags)
    tags = tags.where("LOWER(name) LIKE '%#{term.downcase}%'") if term.present?
    tags = tags.where("name NOT IN (?)", selection) if selection.present?
    return (tags || []).paginate(:page => page, :per_page => per_page)
  end

  private
  
  def check_group_user_access
    if !(Group.get_groups_for_current_user(self.user_id).collect(&:id).include?(self.group_id))
      errors.add(:group_id, "is not valid")
    else
      players = self.transactions_users.collect(&:user_id).push(self.user_id).uniq
      if !(players & Group.find_by_id(self.group_id).users.collect(&:id) == players.uniq)
        errors.add(:user_id, "/Beneficiaries are not valid")
      end
    end
  end
end


