class AddTransactionTypeToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :transaction_type, :integer
  end
end
