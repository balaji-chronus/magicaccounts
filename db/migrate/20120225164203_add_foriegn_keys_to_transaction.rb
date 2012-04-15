class AddForiegnKeysToTransaction < ActiveRecord::Migration
  def self.up
    execute %{alter table transactions
              add constraint fk_transactions_account_id
              foreign key (account_id)
              references accounts(id)
              ON DELETE CASCADE ON UPDATE CASCADE}
    
    execute %{alter table transactions
              add constraint fk_transactions_user_id
              foreign key (user_id)
              references users(id)
              ON DELETE CASCADE ON UPDATE CASCADE}

  end

  def self.down
    execute %{alter table transactions
              drop foreign key fk_transactions_account_id}

    execute %{alter table transactions
              drop foreign key fk_transactions_user_id}
    
  end
end
