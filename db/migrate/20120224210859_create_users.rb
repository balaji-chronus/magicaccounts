class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :hashed_password
      t.string :salt
      t.string :email
      t.string :phone
      t.text :address
      t.string :company

      t.timestamps
    end
  end
end
