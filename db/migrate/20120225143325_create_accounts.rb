class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name, :null => 'false'
      t.string :code, :null => 'false'
      t.string :status, :null => 'false'
      t.text :remarks

      t.timestamps
    end
  end
end
