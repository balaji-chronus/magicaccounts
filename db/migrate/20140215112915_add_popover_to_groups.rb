class AddPopoverToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :popover, :boolean , :default => true
  end
end
