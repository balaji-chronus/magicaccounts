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
  validate :amount_greater_than_one_paise
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

  Transaction.find_by_sql(" SELECT  user_id, IFNULL(investments,0) investments, IFNULL(expenditures,0) expenditures
                            FROM    ( SELECT  user_id, SUM(amount) investments
                                      FROM    transactions
                                      where   beneficiary_id is not null
                                      group    by user_id) A LEFT JOIN ( SELECT  beneficiary_id, SUM(amount) expenditures
                                                                    FROM    transactions
                                                                    where   beneficiary_id is not null
                                                                    group   by beneficiary_id) B
                            ON      A.user_id = B.beneficiary_id
                            UNION
                            SELECT  beneficiary_id user_id, IFNULL(investments,0) investments, IFNULL(expenditures,0) expenditures
                            FROM    ( SELECT  user_id, SUM(amount) investments
                                      FROM    transactions
                                      where   beneficiary_id is not null
                                      group    by user_id) A RIGHT JOIN ( SELECT  beneficiary_id, SUM(amount) expenditures
                                                                    FROM    transactions
                                                                    where   beneficiary_id is not null
                                                                    group   by beneficiary_id) B
                            ON      A.user_id = B.beneficiary_id")

  end  
end
