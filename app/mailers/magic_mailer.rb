class MagicMailer < ActionMailer::Base
  default :from => "admin@magicaccounts.com"
  def group_invite(group, toemail)
    @user = User.find_by_id(group.user_id).name
    @group = group
    mail(:to => toemail, :subject => "Magicaccounts - " + User.find_by_id(group.user_id).name + " invited you to join " + group.name)
  end
end
