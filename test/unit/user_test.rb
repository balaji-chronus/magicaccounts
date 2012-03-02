require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def test_valid_record
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.save
    assert user.valid?, "User should be a valid user"
  end

  def test_valid_name
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.save!
    assert user.valid?, "User should be a valid user"
    assert_equal user.name, "John Locke"
  end

  def test_validate_invalid_name
    user = users(:kate_austen)
    user.update_attributes({ :name => ''})
    assert !user.valid?, "user should have been invalid"
    assert_not_nil user.errors.get(:name), "Blank name should throw an error"
  end

  def test_duplication_of_name        
    user1 = User.create(:name=> "John Locke", :password => "123456", :password_confirmation => "123456", :email => "john.locke@gmail.com", :phone => "9887877889", :user_type => "User")
    assert_not_nil user1.errors.get(:name), "Should validate for duplication of name"
  end

  def test_password_is_encrypted
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.save!
    assert user.valid?, "User should be a valid user"
    assert_not_equal user.password, user.hashed_password
  end

  def test_validate_password_confirmation
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "balaji"
    user.save
    assert_not_nil user.errors.get(:password), "Should validate for password Mismatch"
  end

  def test_should_require_email
    user = users(:john_locke)
    user.email = ""
    user.save
    assert_not_nil user.errors.get(:password), "Should validate for presence of email"
  end

  def test_phone_should_be_atleast_ten_characters

  end

  def test_phone_cannot_exceed_eleven_characters

  end

  def test_phone_should_be_a_number

  end

  def test_email_should_be_properly_formatted

  end
  
  def test_email_invalid_format_is_invalid
    
  end

  def test_name_shall_not_exceed_fifty_characters

  end

  def test_name_length_greater_than_fifty_is_invalid

  end





end
