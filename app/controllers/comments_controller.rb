class CommentsController < ApplicationController
  def recent_activities
    @activitytran = Comment.where(["commentable_type = 'Transaction' AND commentable_id IN (?)", Transaction.get_user_transactions(current_user).collect(&:id)]).order("created_at DESC")
  end
end