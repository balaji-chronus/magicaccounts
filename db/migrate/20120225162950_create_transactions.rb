class CreateTransactions < ActiveRecord::Migration
  def up
    create_table :transactions do |t|
      t.datetime :txndate, :null => 'false'
      t.integer :account_id, :null => 'false'
      t.integer :user_id, :null => 'false'      
      t.decimal :amount, :null => 'false', :precision => 14, :scale => 2
      t.string :category, :null=> 'false'
      t.text :remarks

      t.timestamps
    end
  end
  def down
    drop_table :transactions
  end
end
