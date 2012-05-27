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
end