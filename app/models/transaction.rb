class Transaction < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :account
  has_many    :comments, :as => :commentable
  has_many    :users, :through => :transactions_users
  has_many    :transactions_users, :dependent => :destroy
  accepts_nested_attributes_for :transactions_users, :reject_if => lambda { |a| a[:amount].blank? }, :allow_destroy => true

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id, type: 'integer'
    indexes :account, type: 'integer'
    indexes :category, boost: 5
    indexes :remarks, analyzer: 'snowball', boost: 10
    indexes :txndate, type: 'date'
    indexes :created_at, type: 'date'
    indexes :updated_at, type: 'date'
    indexes :account_name
  end
  
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
    ["Miscellaneous", "miscellaneous"]
  ]

  TRANSACTION_TYPES = [
    ["Track a Personal Expense","1"],
    ["Group - Split Equally", "2"],
    ["Group - Not Split Equally", "3"]
  ]
  
  validates :txndate,   :remarks, :presence => {:message => "Cannot be blank"}
  validates :category,  :inclusion => { :in => CATEGORIES.collect {|val| val[1]}}
  #validates :user_id,   :inclusion => { :in => ->{User.find(:all).collect(&:id)}, :message => 'Select an investor from the list'}
  #validates :account_id,:inclusion => { :in => ->{Account.find(:all).collect(&:id)}, :message => 'Account is not valid'}
  validates :user_id, :existence => true
  validates :account_id, :existence => true
  validates :transactions_users, :presence => true

  def self.balance(sessionuser)

  Transaction.find_by_sql([" SELECT	Y.group_id, Y.id account_id, U.name user_name, investments, expenditures
                            FROM    ( SELECT	R1.account_id, R1.user_id, IFNULL(investments, 0) investments, expenditures
                                      FROM 	( SELECT	account_id, user_id, SUM(amount) expenditures
                                              FROM    transactions_beneficiaries A
                                              WHERE 	beneficiary_id = ?
                                              GROUP   BY account_id, user_id) R1
                                              LEFT	JOIN
                                              (SELECT	account_id, beneficiary_id, SUM(amount) investments
                                              FROM    transactions_beneficiaries A
                                              WHERE   user_id = ?
                                              GROUP   BY account_id, beneficiary_id) R2
                                      ON    R1.account_id = R2.account_id
                                      and   R1.user_id = R2.beneficiary_id
                                      UNION
                                      SELECT	R2.account_id, R2.beneficiary_id user_id, investments, IFNULL(expenditures,0) expenditures
                                      FROM 	( SELECT	account_id, user_id, SUM(amount) expenditures
                                              FROM    transactions_beneficiaries A
                                              WHERE   beneficiary_id = ?
                                              GROUP   BY account_id, user_id) R1
                                      RIGHT	JOIN
                                           (  SELECT	account_id, beneficiary_id, SUM(amount) investments
                                              FROM    transactions_beneficiaries A
                                              WHERE   user_id = ?
                                              GROUP   BY account_id, beneficiary_id) R2
                                      ON    R1.account_id = R2.account_id
                                      and   R1.user_id = R2.beneficiary_id) X JOIN accounts Y
                            ON        X.account_id = Y.id                            
                            JOIN      users U
                            ON        X.user_id = U.id ", sessionuser,sessionuser,sessionuser,sessionuser])

  end

  def self.view_transactions(user, ids)
    Transaction.find_by_sql(['
      SELECT 	id,
              amount,
              CASE 	WHEN amount - net_amount = 0 THEN CONCAT("Your Expenditure is ", amount)
                WHEN type = "investor" THEN CONCAT("Your Investment is ", amount - net_amount)
                WHEN type = "beneficiary" THEN CONCAT("Your Expenditure is ", net_amount)
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
    Transaction.find_by_sql([" SELECT	#{parameter}, SUM(amount) spend, COUNT(DISTINCT id) txn_count
                            FROM	transactions_beneficiaries
                            WHERE	((user_id <> ? AND	beneficiary_id = ?) OR (user_id = ? AND	beneficiary_id = ?))
                            AND	category != 'settlement'
                            #{start_time.blank? ? "" : " AND txndate BETWEEN '#{start_time}' AND '#{end_time}' "}
                            GROUP	BY #{parameter}", user, user, user, user])
  end

  def self.search(params)
    tire.search(page: params[:page] || 1, per_page: 10) do
      query { string params[:query], default_operator: "AND" } if params[:query].present?
      filter :range, txndate: {gte: params[:transaction_start_date]} if params[:transaction_start_date].present?
      filter :range, txndate: {lte: params[:transaction_end_date]} if params[:transaction_end_date].present?
      filter :term, account_id: params[:accountid]
      filter :term, category: params[:category] if params[:category].present? && params[:category] != "all"
      sort { by :txndate, 'desc' }
    end
  end

  def to_indexed_json
    to_json(methods: [:account_name])
  end

  def account_name
    self.account.name
  end
end


