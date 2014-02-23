module GroupsHelper
  def get_owner_member_details(user, group)
    if group.user == user
      return "Owner", "success"
    else
      return "Member", "default"
    end
  end

	def get_activity_group(group)
	  @activitytran = Comment.where(["commentable_type = 'Transaction' AND commentable_id IN (?)", Transaction.get_user_transactions(current_user).collect(&:id)]).order("created_at DESC")
	  @activitytran.select{ |x| x.group_id == group.id}
	end
end