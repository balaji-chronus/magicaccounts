module ApplicationHelper
  def generate_random_number
    return SecureRandom.uuid.gsub("-", "").hex
  end

  def active_tab?(controller, tab_controller)
    return controller == tab_controller
  end

	def transaction_statement(group_ps,summary)
		payer = group_ps.users[current_user.id] 
		trans = payer.blank? ? {} : payer.transaction_partners 
		trans.keys.each do |trans_user|
			user = User.find(trans_user)
			user_name = user.name
			user_image =render_user_image(user,:size => 32)
			if Transaction.user_group_balance(group_ps.group,current_user).balance > 0
				summary << "#{user_image}<b style = 'color: rgb(24, 188, 156); font-size: 22px;'> #{user_name} </b><b style= 'font-size:13px;'> owes you Rs. #{trans[trans_user]}</b>"
			else
				summary << "#{user_image}<b style ='color: rgb(255, 50, 47); font-size: 22px;'> #{user_name} </b><b style= 'font-size:13px;'> You Owe Rs. #{trans[trans_user]}</b>"
			end
		end
		return summary
	end
end
