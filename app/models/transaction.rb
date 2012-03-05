class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :account  
  has_many :comments, :as => :commentable
  has_and_belongs_to_many :users, :uniq => true
  
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


  validates_numericality_of :amount, :greater_than => 0.01
  validates :amount, :txndate, :remarks, :presence => {:message => "Cannot be blank"}  
  validates_inclusion_of :category, :in => CATEGORIES.map {|name,val| val}
  validates_inclusion_of :user_id, :in => User.find(:all).map {|user| user.id}, :message => 'Select an investor from the list'
  #validates_inclusion_of :beneficiary_id, :in => User.find(:all).map {|user| user.id}, :message => 'Select a Beneficiary from the list'
  validates_inclusion_of :account_id, :in => Account.find(:all).map {|account| account.id}, :message => 'Select an account from the list'

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
    Kaminari.paginate_array(Transaction.find_by_sql(["
                              SELECT *
                              FROM   (SELECT  A.id,
                                              A.amount,
                                              CASE  WHEN A.user_id = ? AND GROUP_CONCAT(CONCAT('|',B.user_id,'|')) LIKE CONCAT('%|',?,'|%') THEN CASE WHEN A.amount - (A.amount/ COUNT(B.user_id)) > 0 THEN CONCAT('Your investment is Rs. ', A.amount - ROUND(A.amount/ COUNT(B.user_id),2)) ELSE CONCAT('Your expenditure is Rs. ', A.amount) END
                                                    WHEN A.user_id = ? THEN CONCAT('Your investment is Rs. ', A.amount)
                                                    WHEN GROUP_CONCAT(CONCAT('|',B.user_id,'|')) LIKE CONCAT('%|',?,'|%') THEN CONCAT('Your expenditure is Rs. ', ROUND(A.amount/ COUNT(B.user_id),2))
                                              ELSE  'NA' END details,
                                              A.remarks,
                                              IFNULL(A.updated_at, A.created_at) created_at
                                      FROM    transactions A JOIN transactions_users B
                                      ON      A.account_id = ?
                                      AND     A.id = B.transaction_id                                      
                                      GROUP   BY A.id )tmp
                              WHERE   details <> 'NA'
                              ORDER   BY created_at DESC ", user,user,user,user,account])).page(page).per(5)
  end
end


