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
  belongs_to  :group
  has_many    :comments, :as => :commentable
  has_many    :users, :through => :transactions_users
  has_many    :transactions_users, :dependent => :destroy
  accepts_nested_attributes_for :transactions_users, :reject_if => lambda { |a| a[:amount].blank? }, :allow_destroy => true  
  

  def search_transactions(options = {})
    
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
                WHERE   txndate between ? AND ? +
                ((params[:group_id].present?) ? "AND group_id = #{params[:group_id]}" : " ") +
                ((params[:query].present?) ? "AND LOWER(remarks) LIKE '%#{params[:query].downcase}%'" : " ") +
                'GROUP   BY A.id )tmp
      WHERE     type <> "none"
      ORDER     BY txndate DESC, created_at DESC ', user.id, 
                                                    user.id, 
                                                    user.id,
                                                    params[:groupid],
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
    Transaction.joins("JOIN transactions_users TU ON transactions.id = TU.transaction_id").where("transactions.user_id = ? OR TU.user_id = ?", user.id, user.id).order("transactions.txndate DESC, transactions.updated_at DESC").limit(15)
  end

  def self.user_balance(group)
    Transaction.find_by_sql(["  SELECT X.group_id, X.user_id, investments, expenditures
                                FROM  ( SELECT A.group_id, A.user_id, investments, IFNULL(expenditures, 0) expenditures
                                        FROM    ( SELECT  group_id, user_id, SUM(amount) investments
                                                  FROM    transactions
                                                  WHERE   group_id = #{group.id}
                                                  GROUP   BY group_id, user_id ) A LEFT JOIN (  SELECT  group_id, beneficiary_id, SUM(amount) expenditures
                                                                                      FROM    transactions_beneficiaries
                                                                                      WHERE   group_id = #{group.id}
                                                                                      GROUP   BY group_id, beneficiary_id) B
                                        ON      A.user_id = B.beneficiary_id
                                        AND     A.group_id = B.group_id
                                        UNION
                                        SELECT  Z.group_id, beneficiary_id, IFNULL(investments,0), expenditures
                                        FROM    ( SELECT  group_id, user_id, SUM(amount) investments
                                                  FROM    transactions
                                                  WHERE   group_id = #{group.id}
                                                  GROUP   BY group_id, user_id ) Y RIGHT JOIN ( SELECT  group_id, beneficiary_id, SUM(amount) expenditures
                                                                                      FROM    transactions_beneficiaries
                                                                                      WHERE   group_id = #{group.id}
                                                                                      GROUP   BY group_id, beneficiary_id) Z
                                        ON      Y.user_id = Z.beneficiary_id
                                        AND     Y.group_id = Z.group_id ) X
                            ORDER     BY (investments - expenditures) DESC"])
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


