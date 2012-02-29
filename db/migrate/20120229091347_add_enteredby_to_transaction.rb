class AddEnteredbyToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :enteredby, :string
  end
end
