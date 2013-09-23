class AddActorsToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :actors, :string, :limit => 2048
  end
end
