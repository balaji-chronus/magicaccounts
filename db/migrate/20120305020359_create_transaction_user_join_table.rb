class CreateTransactionUserJoinTable < ActiveRecord::Migration
    def up
    create_table :transactions_users, :id => false do |t|
      t.integer :transaction_id
      t.integer :user_id
    end
  end

  def down
    drop_table :transactions_users
  end
end
