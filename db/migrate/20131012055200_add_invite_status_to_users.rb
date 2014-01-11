class AddInviteStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :invite_status, :string, :default => "not_registered"
  end
end
