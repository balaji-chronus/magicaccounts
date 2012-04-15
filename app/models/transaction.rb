class Transaction < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :account
  has_many    :comments, :as => :commentable
  has_many    :users, :through => :transactions_users
  has_many    :transactions_users, :dependent => :destroy
  accepts_nested_attributes_for :transactions_users, :reject_if => lambda { |a| a[:amount].blank? }, :allow_destroy => true
  
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

  def self.view_transactions(user, account, page)    
    Kaminari.paginate_array(Transaction.find_by_sql(['
                              SELECT 	id,
                                      amount,
                                      CASE 	WHEN net_amount = 0 THEN CONCAT("Your Expenditure is ", amount)
                                        WHEN type = "investor" THEN CONCAT("Your Investment is ", net_amount)
                                        WHEN type = "beneficiary" THEN CONCAT("Your Expenditure is ", net_amount)
                                      END	details,
                                      remarks,
                                      created_at
                              FROM   	( SELECT  A.id,
                                                CASE WHEN A.user_id = ? THEN "investor" WHEN COUNT(CASE WHEN B.user_id = ? THEN 1 ELSE 0 END) >= 1 THEN "beneficiary" ELSE "none" END type,
                                                SUM(B.amount) - SUM(CASE WHEN B.user_id = ? THEN B.amount ELSE 0 END) net_amount,
                                                SUM(B.amount) amount,
                                                A.remarks,
                                                IFNULL(A.updated_at, A.created_at) created_at
                                        FROM    transactions A JOIN transactions_users B
                                        ON      A.account_id = ?
                                        AND     A.id = B.transaction_id
                                        GROUP   BY A.id )tmp
                              WHERE     type <> "none"
                              ORDER     BY created_at DESC ', user,user,user,account])).page(page).per(5)
  end
end


