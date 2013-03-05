# Mailer class
class MagicMailer < ActionMailer::Base
  default :from => "admin@magicaccounts.com"
  def group_invite(group, toemail)
    @user = User.find_by_id(group.user_id).name
    @group = group
    mail(:to => toemail, :subject => "Magic Accounts - #{User.find_by_id(group.user_id).name} invited you to join #{group.name}")
  end

  def registration_success(user)
    @user = user
    mail(:to => user.email, :subject => "Magic Accounts - You have been successfully registered ! ")
  end

  def transaction_notification(transaction, action, amount, beneficiary)
    @transaction = transaction
    @action = action
    @amount = amount.round
    @beneficiary = beneficiary
    mail(:to => beneficiary.email, :subject => "Magic Accounts - Transaction notification")
  end
end



