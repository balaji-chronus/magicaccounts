class TransactionsUser < ActiveRecord::Base
  validates_numericality_of :amount, :greater_than => 0.01
  
  belongs_to :user
  belongs_to :transaction
end
