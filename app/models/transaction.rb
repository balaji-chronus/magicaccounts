class Transaction < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

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

  validates :txndate,   :remarks, :presence => {:message => "Cannot be blank"}
  validates :category,  :inclusion => { :in => CATEGORIES.collect {|val| val[1]}}
  validates :transactions_users, :presence => true
  validate  :check_group_user_access

  belongs_to  :user
  belongs_to  :group
  has_many    :comments, :as => :commentable
  has_many    :users, :through => :transactions_users
  has_many    :transactions_users, :dependent => :destroy
  accepts_nested_attributes_for :transactions_users, :reject_if => lambda { |a| a[:amount].blank? }, :allow_destroy => true  

  mapping do
    indexes :id, type: 'integer'
    indexes :group_id, type: 'integer'
    indexes :category, boost: 5
    indexes :remarks, analyzer: 'snowball', boost: 10
    indexes :txndate, type: 'date'
    indexes :created_at, type: 'date'
    indexes :updated_at, type: 'date'
    indexes :group_name
    indexes :players, type: 'integer'
  end

  def self.balance(sessionuser)

  Transaction.find_by_sql([" SELECT	X.group_id, U.name user_name, investments, expenditures
                            FROM    ( SELECT	R1.group_id, R1.user_id, IFNULL(investments, 0) investments, expenditures
                                      FROM 	( SELECT	group_id, user_id, SUM(amount) expenditures
                                              FROM    transactions_beneficiaries A
                                              WHERE 	beneficiary_id = ?
                                              GROUP   BY group_id, user_id) R1
                                              LEFT	JOIN
                                              (SELECT	group_id, beneficiary_id, SUM(amount) investments
                                              FROM    transactions_beneficiaries A
                                              WHERE   user_id = ?
                                              GROUP   BY group_id, beneficiary_id) R2
                                      ON    R1.group_id = R2.group_id
                                      and   R1.user_id = R2.beneficiary_id
                                      UNION
                                      SELECT	R2.group_id, R2.beneficiary_id user_id, investments, IFNULL(expenditures,0) expenditures
                                      FROM 	( SELECT	group_id, user_id, SUM(amount) expenditures
                                              FROM    transactions_beneficiaries A
                                              WHERE   beneficiary_id = ?
                                              GROUP   BY group_id, user_id) R1
                                      RIGHT	JOIN
                                           (  SELECT	group_id, beneficiary_id, SUM(amount) investments
                                              FROM    transactions_beneficiaries A
                                              WHERE   user_id = ?
                                              GROUP   BY group_id, beneficiary_id) R2
                                      ON    R1.group_id = R2.group_id
                                      and   R1.user_id = R2.beneficiary_id) X
                            JOIN      users U
                            ON        X.user_id = U.id ", sessionuser,sessionuser,sessionuser,sessionuser])

  end

  def self.view_transactions(user, ids)
    Transaction.find_by_sql(['
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
                WHERE   A.id IN (?)
                GROUP   BY A.id )tmp
      WHERE     type <> "none"
      ORDER     BY txndate DESC, created_at DESC ', user,user,user,ids])
  end

  def self.spend_by(parameter, user, start_time, end_time)
    Transaction.find_by_sql([" SELECT	#{parameter}, SUM(ROUND(amount)) spend, COUNT(DISTINCT id) txn_count
                            FROM	transactions_beneficiaries
                            WHERE	((user_id <> ? AND	beneficiary_id = ?) OR (user_id = ? AND	beneficiary_id = ?))
                            AND	category != 'settlement'
                            #{start_time.blank? ? "" : " AND txndate BETWEEN '#{start_time}' AND '#{end_time}' "}
                            GROUP	BY #{parameter}", user, user, user, user])
  end

  def self.search(params, current_user)
    tire.search(page: params[:page] || 1, per_page: 10) do
      query { string params[:query], default_operator: "AND" } if params[:query].present?
      filter :range, txndate: {gte: params[:transaction_start_date]} if params[:transaction_start_date].present?
      filter :range, txndate: {lte: params[:transaction_end_date]} if params[:transaction_end_date].present?
      filter :term, group_id: params[:groupid]
      filter :term, category: params[:category] if params[:category].present? && params[:category] != "all"
      filter :term, players: current_user.id
      sort { by :txndate, 'desc' }
    end
  end

  def to_indexed_json
    to_json(methods: [:group_name, :players])
  end

  def group_name
    self.group.name
  end

  def players
    self.transactions_users.collect(&:user_id).push(self.user_id).uniq
  end

  def self.get_user_transactions(user)
    results = tire.search(per_page: 15) do
      filter :term, players: user.id
      sort { by :updated_at, 'desc' }
    end

    Transaction.find_by_sql(['
    SELECT  A.id
    FROM    transactions A 
    WHERE   A.id IN (?)
    ORDER   BY txndate DESC, IFNULL(A.updated_at, A.created_at) DESC',results.collect(&:id)])
    
  end

  def self.user_balance_for(group)
    Transaction.find_by_sql(["  SELECT U.name user_name, investments, expenditures
                                FROM  ( SELECT user_id, investments, IFNULL(expenditures, 0) expenditures
                                        FROM    ( SELECT  user_id, SUM(amount) investments
                                                  FROM    transactions
                                                  WHERE   group_id = ?
                                                  GROUP   BY user_id ) A LEFT JOIN (  SELECT  beneficiary_id, SUM(amount) expenditures
                                                                                      FROM    transactions_beneficiaries
                                                                                      WHERE   group_id = ?
                                                                                      GROUP   BY beneficiary_id) B
                                        ON      A.user_id = B.beneficiary_id
                                        UNION
                                        SELECT  user_id, IFNULL(investments,0), expenditures
                                        FROM    ( SELECT  user_id, SUM(amount) investments
                                                  FROM    transactions
                                                  WHERE   group_id = ?
                                                  GROUP   BY user_id ) Y RIGHT JOIN ( SELECT  beneficiary_id, SUM(amount) expenditures
                                                                                      FROM    transactions_beneficiaries
                                                                                      WHERE   group_id = ?
                                                                                      GROUP   BY beneficiary_id) Z
                                        ON      Y.user_id = Z.beneficiary_id ) X
                            JOIN      users U
                            ON        X.user_id = U.id ", group.id, group.id, group.id, group.id])    
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


