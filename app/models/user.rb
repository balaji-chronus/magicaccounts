require 'digest/sha2'
class User < ActiveRecord::Base
  USERTYPES = ["Admin","User"]
  has_many :transactions
  has_and_belongs_to_many :groups
  
  validates :name, :presence => {:message => 'Name cannot be blank'}
  
  validates_uniqueness_of :name

  validates_length_of :phone, 
                      :maximum => 11,                      
                      :too_long => "Phone cannot exceed 11 chars"

  validates_length_of :phone,
                      :minimum => 10,
                      :too_short => "Phone cannot be less than 10 chars"

  validates_format_of :phone,
                      :with => /\d+/,
                      :message => "Only numbers are allowed"

  validates_format_of :email,
                      :with => /.+@.+\..+/,
                      :message => "Please enter a valid email. ex: johndoe@mail.com"
                    
  validate  :password_not_blank

  attr_accessor :password_confirmation
  validates_confirmation_of :password
  validates :password, :presence => {:message => 'Password missing. Enter a minimum of 6 chars'},
            :length => {:minimum => 6, :too_short => 'Enter a minimum of 6 chars'}

  validates :password_confirmation, :presence => {:message => 'Password missing. Enter a minimum of 6 chars'},
            :length => {:minimum => 6, :too_short => 'Enter a minimum of 6 chars'}

  validates_inclusion_of :user_type, :in => USERTYPES, :message => 'Select a user type from the list'



  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end
  

  def self.authenticate(username,password)
    user = User.find_by_name(username)
    if user
      expected_pwd = User.encrypted_password(password, user.salt)
      if expected_pwd != user.hashed_password
        user = nil
      end
    end
    user
  end


  private
  def password_not_blank
    errors.add(:password, "Password cannot be Empty") if hashed_password.blank?
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def self.encrypted_password(pwd,salt)
    string_to_hash = pwd + "takraw" + salt
    Digest::SHA2.hexdigest(string_to_hash)
  end

end
