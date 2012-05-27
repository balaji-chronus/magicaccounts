class RecreateTransactionsBeneficiariesView < ActiveRecord::Migration
  def up
    execute %{  DROP VIEW IF EXISTS transactions_rolled_up }
    execute %{  CREATE  OR REPLACE VIEW transactions_beneficiaries AS
                SELECT	T.id,
                        T.txndate,
                        T.group_id,
                        T.user_id,
                        TU.amount,
                        T.category,
                        T.remarks,
                        T.created_at,
                        T.updated_at,
                        T.enteredby,
                        TU.user_id beneficiary_id
                FROM    transactions T JOIN transactions_users TU
                ON      T.id = TU.transaction_id
             }
  end

  def down
    execute %{  DROP VIEW IF EXISTS transactions_beneficiaries }
  end
end
