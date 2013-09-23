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
end
