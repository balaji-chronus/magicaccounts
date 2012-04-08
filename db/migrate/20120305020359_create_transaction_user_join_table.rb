class CreateTransactionUserJoinTable < ActiveRecord::Migration
    def up
    create_table :transactions_users do |t|
      t.integer :transaction_id
      t.integer :user_id
      t.decimal :amount, :precision => 14, :scale => 2

      t.timestamps
    end
  end

  def down
    drop_table :transactions_users
  end
end
