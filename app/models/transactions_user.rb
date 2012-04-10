class TransactionsUser < ActiveRecord::Base   
  belongs_to :user
  belongs_to :transaction
end
