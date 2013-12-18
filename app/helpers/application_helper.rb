module ApplicationHelper
  def generate_random_number
    return SecureRandom.uuid.gsub("-", "").hex
  end
end
