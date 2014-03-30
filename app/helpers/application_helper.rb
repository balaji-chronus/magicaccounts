module ApplicationHelper
  def generate_random_number
    return SecureRandom.uuid.gsub("-", "").hex
  end

  def active_tab?(controller, tab_controller)
    return controller == tab_controller
  end

	def transaction_statement(array,left,right)
		array.keys.each do |id|
			entry = array[id]
			user = User.find(id)
			user_name = user.name
			user_image =render_user_image(user,:size => 37, :class_name => 'img-circle')
			entry[:mstatement] = content_tag(:ul,raw(entry[:mstatement]))
			if entry[:balance] < 0
				entry[:statement] = "<div><span class='user_image'>#{user_image}</span><span class='user_name text-danger'>#{user_name}</span><br/><span class='balance'>You owe #{entry[:balance].abs}</span></div>"
				left << entry
			else
				entry[:statement] = "<div><span class='user_image'>#{user_image}</span><span class='user_name text-success'>#{user_name}</span><br/><span class='balance'>owes you #{entry[:balance]}</span></div>"
				right << entry
			end
		end
	end

	def compute_summary(paystructure)
		array = Hash.new(Hash.new(""))
		paystructure.each do |group_ps|
			if group_ps.users[current_user.id].present?
			group_name = group_ps.group.name
			user_trans = group_ps.users[current_user.id].transaction_partners
			user_trans.keys.each do |tu|
				if Transaction.user_group_balance(group_ps.group,current_user).balance < 0
				array[tu.id] = {:balance => array[tu.id][:balance].to_i - user_trans[tu] ,:mstatement => array[tu.id][:mstatement] + content_tag(:li,"You owe #{user_trans[tu]} for #{group_name}",:class=>'left')}
				else
				array[tu.id] = {:balance => array[tu.id][:balance].to_i + user_trans[tu],:mstatement => array[tu.id][:mstatement] + content_tag(:li,"owes you #{user_trans[tu]} for #{group_name}",:class=>'right')}
				end
			end
		end
	end
		return array
	end


	def get_width(flag)
		if flag == 0
			@master_balance[:expenses] != 0 ? "#{@master_balance[:expenses] * 100 / (@master_balance[:expenses] + (@master_balance[:investments] || 0)) }%" : 0
		else
			@master_balance[:investments] != 0 ? "#{@master_balance[:investments] * 100 / (@master_balance[:investments] + (@master_balance[:expenses] || 0))}%" : 0
		end
	end
end
