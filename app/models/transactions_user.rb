class TransactionsUser < ActiveRecord::Base   
  belongs_to :user
  belongs_to :transaction, :dependent => :destroy

  after_save :calculate_transaction_amount

  def calculate_transaction_amount
  	self.transaction.update_attributes(:amount => self.transaction.transactions_users.collect(&:amount).compact.inject(:+))
  end
end
