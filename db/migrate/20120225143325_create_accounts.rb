class CreateAccounts < ActiveRecord::Migration
  def up
    create_table :accounts do |t|
      t.string :name, :null => 'false'
      t.string :code, :null => 'false'
      t.string :status, :null => 'false'
      t.text :remarks

      t.timestamps
    end
  end
  def down
    drop_table :accounts;
  end
end
