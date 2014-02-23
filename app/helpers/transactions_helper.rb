module TransactionsHelper

  Summary_metadata = {
    "right" => {
              :display_class => "pull-right text-danger col-sm-6",
              :display_string => "You Owe"
    },

    "left" => {
              :display_class => "pull-left text-success col-sm-6",
              :display_string => "Owes You"
    }
  }

  def render_user_transaction_balance(transaction)
    amount = transaction.amount_paid - (transaction.amount || 0)

    if amount < 0
      display_string = "You Pay"
      display_amount = amount.abs.to_s
      display_class = "text-danger"
    elsif amount > 0
      display_string = "You Get"
      display_amount = amount.to_s
      display_class = "text-success"
    else
      display_string = "Settled Up"
      display_class = "text-muted"
      display_amount = amount.to_s
    end
    return content_tag(:div, display_string, :class => display_class) +
    content_tag(:div, display_amount, :class => display_class + " lead")
  end

  def render_user_transaction_balance_detail(transaction)
    amount = transaction.amount_paid - (transaction.amount || 0)

    if amount < 0
      display_string = "Owes #{amount.abs.to_s}"
      display_class = "icon-minus-sign-alt"
      text_class = "text-danger"
    elsif amount > 0
      display_string = "Gets #{amount.to_s}"
      display_class = "icon-plus-sign-alt"
      text_class = "text-success"
    else
      display_string = "Is Settled Up"
      display_class = "icon-smile"
      text_class = "text-success"
    end
    return display_string, display_class, text_class
  end


  def other_user_transactions_exist(current_user)
    current_user.transactions_users.select{|x| x.amount != x.amount_paid}.empty?
  end

  def render_summary_info(entry)
    if entry.present?
		options = entry[1] > 0 ? Summary_metadata["left"] : Summary_metadata["right"]
		return content_tag(:div, User.find(entry[0]).name.titleize + "                     " + options[:display_string] + " " + entry[1].abs.to_s, :class => options[:display_class])
	else
		return content_tag(:div, " " ,:class => "col-sm-6")
	end

  end
end
