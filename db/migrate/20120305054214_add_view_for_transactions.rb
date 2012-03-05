class AddViewForTransactions < ActiveRecord::Migration
  def up
    execute %{  CREATE  OR REPLACE VIEW transactions_rolled_up AS
                SELECT  A.id,
                        A.amount/COUNT(DISTINCT B.user_id) share,
                        COUNT(DISTINCT B.user_id) user_count
                        FROM    transactions A JOIN transactions_users B
                        ON      A.id = B.transaction_id
                        GROUP   BY A.id;
             }

    execute %{  CREATE  OR REPLACE VIEW transactions_beneficiaries AS
                SELECT	T.id,
                        T.txndate,
                        T.account_id,
                        T.user_id,
                        TUC.share amount,
                        T.category,
                        T.remarks,
                        T.created_at,
                        T.updated_at,
                        T.enteredby,
                        TU.user_id beneficiary_id
                FROM    transactions T JOIN transactions_users TU
                ON      T.id = TU.transaction_id
                JOIN    transactions_rolled_up TUC
                ON      T.id = TUC.id
             }
  end

  def down
    execute %{  DROP VIEW transactions_rolled_up }
    execute %{  DROP VIEW transactions_beneficiaries }
  end
end
