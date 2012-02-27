class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
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
    ["Miscellaneous", "miscellaneous"]
  ]


  validates_numericality_of :amount, :greater_than => 0.01
  validates :amount, :txndate, :remarks, :presence => {:message => "Cannot be blank"}  
  validates_inclusion_of :category, :in => CATEGORIES.map {|name,val| val}
  validates_inclusion_of :user_id, :in => User.find(:all).map {|user| user.id}, :message => 'Select an investor from the list'
  validates_inclusion_of :beneficiary_id, :in => User.find(:all).map {|user| user.id}, :message => 'Select a Beneficiary from the list'
  validates_inclusion_of :account_id, :in => Account.find(:all).map {|account| account.id}, :message => 'Select an account from the list'

  def self.pagination(fromdate,todate,investor,benificiary,amtfrom,amtto,categories,pagenum,recordsperpage,sortcol,sortorder)
    Transaction.find( :all,
                      #:conditions => ["txndate between ? AND ? AND user_id = ? AND benificiary_id = ? AND amount between ? AND ? AND category = ? ", fromdate, todate, investor,benificiary,amtfrom,amtto,categories],
                      :order => ["#{sortcol} #{sortorder}"],
                      :limit => recordsperpage,
                      :offset => (pagenum - 1 ) * recordsperpage)
  end

  def self.balance

  Transaction.find_by_sql(" SELECT	Z.name group_name, Y.name account_name, U.name user_name, investments, expenditures
                            FROM    ( SELECT	R1.account_id, R1.user_id, IFNULL(investments, 0) investments, expenditures
                                      FROM 	( SELECT	account_id, user_id, SUM(amount) expenditures
                                              FROM    transactions A
                                              WHERE 	beneficiary_id = 2
                                              GROUP   BY account_id, user_id) R1
                                              LEFT	JOIN
                                              (SELECT	account_id, beneficiary_id, SUM(amount) investments
                                              FROM    transactions A
                                              WHERE   user_id = 2
                                              GROUP   BY account_id, beneficiary_id) R2
                                      ON    R1.account_id = R2.account_id
                                      and   R1.user_id = R2.beneficiary_id
                                      UNION
                                      SELECT	R2.account_id, R2.beneficiary_id user_id, investments, IFNULL(expenditures,0) expenditures
                                      FROM 	( SELECT	account_id, user_id, SUM(amount) expenditures
                                              FROM    transactions A
                                              WHERE   beneficiary_id = 2
                                              GROUP   BY account_id, user_id) R1
                                      RIGHT	JOIN
                                           (  SELECT	account_id, beneficiary_id, SUM(amount) investments
                                              FROM    transactions A
                                              WHERE   user_id = 2
                                              GROUP   BY account_id, beneficiary_id) R2
                                      ON    R1.account_id = R2.account_id
                                      and   R1.user_id = R2.beneficiary_id) X JOIN accounts Y
                            ON        X.account_id = Y.id
                            JOIN      groups Z
                            on        Y.group_id = Z.id
                            JOIN      users U
                            ON        X.user_id = U.id ")

  end  
end


