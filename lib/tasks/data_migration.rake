namespace :migration do
  desc "One Time migration to move to group id from account id"
  task :migrate_group_id_from_account_id => :environment do
    ActiveRecord::Base.connection.execute("
      SET SQL_SAFE_UPDATES=0;")

    ActiveRecord::Base.connection.execute("
      UPDATE transactions A JOIN accounts B
      ON A.account_id = B.id      
      SET A.group_id = B.group_id;")
    
    ActiveRecord::Base.connection.execute("
      SET SQL_SAFE_UPDATES=1;")
  end

  desc "One Time migration to calculate amount "
  task :migrate_amount_to_transaction => :environment do
    Transaction.all.each do |tran|
      tran.update_attributes(:amount => tran.transactions_users.collect(&:amount).inject(:+))
    end
  end

  desc "One Time migration to set the category to category tags"
  task :migrate_category_tags => :environment do
    Transaction.record_timestamps=false

    Transaction.all.each do |transaction|
      transaction.update_attributes(:tag_list => transaction.tag_list.concat([transaction.category]).join(","))
    end

    Transaction.record_timestamps=false
  end
end