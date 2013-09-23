class AddAmountPaidToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions_users, :amount_paid, :decimal, :precision => 14, :scale => 2, :default => 0
  end
end
