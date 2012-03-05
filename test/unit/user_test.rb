require 'test_helper'
require 'digest/sha2'

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
    user.name = "james200_sawyer2011"
    user.password = "123456"
    user.password_confirmation = "123456"
    user.save
    assert user.valid?, "User should be a valid user as name '#{user.name}' was valid"
  end

   def test_valid_name_with_digits_inbetween
    user = users(:one)
    user.name = "James1Ford"
    user.password = "123456"
    user.password_confirmation ="123456"
    
    user.save
    assert user.valid?, "Should not fail as name #{user.name}can accept digits inbetween"
  end

  def test_valid_name_with_underscores_inbetween
    user = users(:one)
    user.name = "James_Ford"
    user.password = "123456"
    user.password_confirmation ="123456"
    
    user.save
    assert user.valid?, "Should not fail as name #{user.name} can accept underscores in between"
  end

  def test_invalid_name_exceeds_allowed_length
    user = users(:one)
    user.name = "Namex_Namex_Namex_Namex_Namex_Namex_Namex_Namex_Namex_Namex"
    user.password = "123456"
    user.password_confirmation ="123456"

    user.save
    assert !user.valid?, "Should fail as name#{user.name} exceeds allowed limit"
    assert_not_nil user.errors.get(:name), "Should have an error for name exceeding limit"
  end

  def test_invalid_name_without_minimum_characters
    user = users(:one)
    user.name = "Na"
    user.password = "123456"
    user.password_confirmation ="123456"

    user.save
    assert !user.valid?, "Should fail as name#{user.name} falls below required limit"
    assert_not_nil user.errors.get(:name), "Should have an error for name falling below required limit"
  end

  def test_invalid_empty_name
    user = users(:kate_austen)
    user.name = ""
    user.password = "123456"
    user.password_confirmation = "123456"

    user.update_attributes({ :name => ''})
    assert !user.valid?, "user should have been invalid"
    assert_not_nil user.errors.get(:name), "Blank name should throw an error"
  end

  def test_invalid_duplicate_name
    user = User.create(:name=> users(:one).name, :password => "123456", :password_confirmation => "123456", :email => "john.locke@gmail.com", :phone => "9887877889", :user_type => "User")
    assert !user.valid?, "user should have been invalid"
    assert_not_nil user.errors.get(:name), "Should validate for duplication of name #{user.name}"
  end

  def test_invalid_name_has_whitespaces
    user = users(:one)    
    user.password = "123456"
    user.password_confirmation = "123456"    
    user.name = "James Ford"

    user.save
    assert !user.valid?, "user should have been invalid"
    assert_not_nil user.errors.get(:name), "#{user.name} Name should not allow spaces"
  end

  def test_invalid_name_has_special_characters
    user = users(:one)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.name = "James&Ford"
    
    user.save
    assert !user.valid?, "user should have been invalid"
    assert_not_nil user.errors.get(:name), "#{user.name} Name should not allow special charaters"
  end

  def test_invalid_starts_not_with_an_alphabet
    user = users(:one)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.name = "2011Baaju"
    
    user.save
    assert !user.valid?, "user should have been invalid"
    assert_not_nil user.errors.get(:name), "#{user.name} Name should start with an alphabet"
  end 

  def test_invalid_name_ends_with_an_underscore
    user = users(:one)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.name = "Jamesford_"

    user.save
    assert !user.valid?, "user should have been invalid"
    assert_not_nil user.errors.get(:name), "Name should not end with an underrscore"
  end    

  def test_valid_password_is_encrypted
    user = User.create(:name=> "hugo_reyes", :salt=> "MYOWNSALT", :hashed_password => "MYHASHEDPASSWORD", :password => "123456", :password_confirmation => "123456", :email => "john.locke@gmail.com", :phone => "9887877889", :user_type => "User")
    
    assert user.valid?, "User should be a valid user"
    assert_not_equal user.password, user.hashed_password, "Hashed password equal to entered password"
    assert_not_equal user.salt, "MYOWNSALT", "Salt was not generated randomly"
    assert_not_equal user.hashed_password, "MYHASHEDPASSWORD", "Hashed Password not generated"    
  end

  def test_valid_password_encryption_logic    
    user = User.create(:name=> "hugo_reyes", :salt=> "MYOWNSALT", :hashed_password => "MYHASHEDPASSWORD", :password => "123456", :password_confirmation => "123456", :email => "john.locke@gmail.com", :phone => "9887877889", :user_type => "User")
    
    assert user.valid?, "User should be a valid user"
    assert_not_equal user.hashed_password, Digest::SHA2.hexdigest("123456takraw" + "MYOWNSALT"), "Password encryption logic crtical security bug"
    assert_equal user.hashed_password, Digest::SHA2.hexdigest("123456takraw" + user.salt), "Password encrytiopm logic Wrong"
  end

  def test_invalid_empty_password
    user = users(:john_locke)
    user.password = ""
    user.password_confirmation = "123456"
    
    user.save
    assert !user.valid?, "User should be invalid as password is empty"
    assert_not_nil user.errors.get(:password), "Password empty should throw an error"
  end

  def test_invalid_empty_password_confirmation
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = ""

    user.save
    assert !user.valid?, "User should be invalid as password confirm is empty"
    assert_not_nil user.errors.get(:password), "Password empty should throw an error"
  end

  def test_invalid_password_dont_match
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "balaji"

    user.save
    assert !user.valid?, "User should be invalid as password doesn't match with confirmation"
    assert_not_nil user.errors.get(:password), "Should validate for password Mismatch"
  end

  def test_invalid_password_without_minimum_limit
    user = users(:john_locke)
    user.password = "12"
    user.password_confirmation = "12"

    user.save
    assert !user.valid?, "User should be invalid as password falls below required character limit"
    assert_not_nil user.errors.get(:password), "Should validate for minimum required limit for password"
  end

  def test_invalid_password_exceeds_maximum_limit
    user = users(:john_locke)
    user.password = "1234567890123456"
    user.password_confirmation = "1234567890123456"

    user.save
    assert !user.valid?, "User should be invalid as exceed maximum character limit"
    assert_not_nil user.errors.get(:password), "Should validate for maximum limit for password"
  end


  def test_valid_email
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.email = "balaji_seetharaman.sree@gmail.com"

    user.save!
    assert user.valid?, "User should be valid as email #{user.email} is valid"    
  end  

  def test_invalid_empty_email
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.email = ""

    user.save
    assert !user.valid?, "User should be invalid as email #{user.email} is not valid"
    assert_not_nil user.errors.get(:email), "Should validate for presence of email"
  end

  def test_invalid_email_without_atom
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.email = "balajiseethamangmail.com"

    user.save
    assert !user.valid?, "User should be invalid as email #{user.email} is not valid"
    assert_not_nil user.errors.get(:email), "Should validate email for atom"
  end

  def test_invalid_email_without_trailing_domain
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.email = "balajiseethaman@gmailcom"

    user.save
    assert !user.valid?, "User should be invalid as email #{user.email} is not valid"
    assert_not_nil user.errors.get(:email), "Should validate email for trailing domain"
  end

  def test_invalid_email_atom_and_trailing_domain_swapped
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.email = "balajiseethaman.gmail@com"

    user.save
    assert !user.valid?, "User should be invalid as email #{user.email} is not valid"
    assert_not_nil user.errors.get(:email), "Should validate email for order of the atom and trailing domain"
  end

  def test_invalid_email_character_trailing_domain_is_not_an_alphabet_or_digit
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.email = "balajiseethaman@gmail_.com"

    user.save
    assert !user.valid?, "User should be invalid as email #{user.email} is not valid"
    assert_not_nil user.errors.get(:email), "Should validate email for last character prior to atom"
  end  

  def test_invalid_email_exceeds_maximum_limit
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.email = "balajiseetharamanbalajiseetharamanbalajiseetharamanbalajiseet
                  haramanbalajiseetharamanbalajiseetharamanbalajiseetharaman@gmail.com"

    user.save
    assert !user.valid?, "User should be invalid as email #{user.email} exceeds max limit"
    assert_not_nil user.errors.get(:email), "Should validate email for maximum limit"
  end

  def test_valid_phone
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.phone = "1123426374"

    user.save!
    assert user.valid?, "User shudbe valid as the phone #{user.phone} is valid"    
  end

  def test_invalid_phone_contains_non_numbers
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.phone = "11234263a@"

    user.save
    assert !user.valid?, "User shud not be valid as the phone #{user.phone} contains non numbers"
    assert_not_nil user.errors.get(:phone), "Should validate phone for non digits"
  end

  def test_invalid_phone_less_than_ten_chars
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.phone = "998347332"

    user.save
    assert !user.valid?, "User shud not be valid as the phone #{user.phone} is less than 10 digits"
    assert_not_nil user.errors.get(:phone), "Should validate phone for minlength"
  end

  def test_invalid_phone_exceeds_eleven_chars
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.phone = "998347332123"

    user.save
    assert !user.valid?, "User shud not be valid as the phone #{user.phone} is more than 11 digits"
    assert_not_nil user.errors.get(:phone), "Should validate phone for maxlength"
  end

  def test_valid_address
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.address = "2021 W Olive Avenue Burbank CA 91506"

    user.save!
    assert user.valid?, "User should be valid as the address is valid"    
  end

  def test_valid_address_empty
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.address = ""

    user.save!
    assert user.valid?, "User should be valid as the empty address is valid"
  end

  def test_invalid_address_exceeds_limit
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.address = "2021 W Olive Avenue Burbank CA 91506 2021 W Olive Avenue 
                    Burbank CA 915062021 W Olive Avenue Burbank CA 915062021
                    W Olive Avenue Burbank CA 915062021 W Olive Avenue Burbank
                    CA 915062021 W Olive Avenue Burbank CA 915062021 W Olive
                    Avenue Burbank CA 915062021 W Olive Avenue Burbank CA
                    915062021 W Olive Avenue Burbank CA 915062021 W Olive Avenue
                    Burbank CA 915062021 W Olive Avenue Burbank CA 915062021
                    W Olive Avenue Burbank CA 915062021 W Olive Avenue Burbank
                    CA 915062021 W Olive Avenue Burbank CA 91506"

    user.save
    assert !user.valid?, "User should not be valid as the address #{user.address}exceeds limit"
    assert_not_nil user.errors.get(:address), "Should validate address #{user.address} for limit"
  end

  def test_valid_company
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.company = "Company X"

    user.save!
    assert user.valid?, "User should be valid as the company is valid"
  end

  def test_valid_company_empty
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.company = ""

    user.save!
    assert user.valid?, "User should be valid as empty company is valid"
  end

  def test_invalid_company_exceeds_limit
    user = users(:john_locke)
    user.password = "123456"
    user.password_confirmation = "123456"
    user.company = "2021 W Olive Avenue Burbank CA 91506 2021 W Olive Avenue
                    Burbank CA 915062021 W Olive Avenue Burbank CA 915062021
                    W Olive Avenue Burbank CA 915062021 W Olive Avenue Burbank"
    
    user.save
    assert !user.valid?, "User should not be valid as the company #{user.company}exceeds limit"
    assert_not_nil user.errors.get(:company), "Should validate company #{user.company} for limit"
  end  


end
