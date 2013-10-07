module TransactionsHelper
  def render_user_transaction_balance(transaction)
    amount = transaction.amount_paid - transaction.amount

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
    amount = transaction.amount_paid - transaction.amount

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
end
