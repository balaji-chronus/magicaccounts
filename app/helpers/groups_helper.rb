module GroupsHelper
  def get_owner_member_details(user, group)
    if group.user == user
      return "Owner", "success"
    else
      return "Member", "default"
    end
  end
end
