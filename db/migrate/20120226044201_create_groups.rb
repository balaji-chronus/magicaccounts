class CreateGroups < ActiveRecord::Migration
  def up
    create_table :groups do |t|
      t.string :name
      t.string :status
      t.integer :user_id

      t.timestamps
    end
  end
  def down
    drop_table :groups
  end
end
