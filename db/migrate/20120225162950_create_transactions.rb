class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.datetime :txndate, :null => 'false'
      t.integer :account_id, :null => 'false'
      t.integer :user_id, :null => 'false'
      t.integer :beneficiary_id
      t.decimal :amount, :null => 'false', :precision => 14, :scale => 2
      t.string :category, :null=> 'false'
      t.text :remarks

      t.timestamps
    end
  end
end
