module ApplicationHelper
  def generate_random_number
    return SecureRandom.uuid.gsub("-", "").hex
  end

  def active_tab?(controller, tab_controller)
    return controller == tab_controller
  end
end
