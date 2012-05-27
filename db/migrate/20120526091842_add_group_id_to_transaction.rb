class AddGroupIdToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :group_id, :integer
  end
end
