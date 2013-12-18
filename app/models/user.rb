require 'digest/sha2'
class User < ActiveRecord::Base  

  module INVITE_STATUS
    REGISTERED = "registered"
    NOT_REGISTERED = "not_registered"
  end

  has_many :transactions
  has_many :groups
  has_and_belongs_to_many :user_groups, :class_name => "Group", :uniq => true
  has_many :transaction_items, :class_name => "Transaction", :through => :transactions_users
  has_many :transactions_users
  has_many :comments

  attr_accessor :password_confirmation
  
  validates :name,
            :format => {:with => /^[a-zA-Z]+[a-zA-Z0-9_]*[a-zA-Z0-9]+$/, :message => 'Name must have at least one alphabet and contain only alphabets, digits, or underscores'},
            :length => {:in => 4..32, :message => "should be between 4 and 15 characters"}

  validates :phone,
            :length => { :in => 10..11, :message => "Enter a phone number between with 10 or 11 digits", :allow_blank => true, :allow_nil => true },
            :format => { :with => /^[0-9]+$/, :message => "Only numbers are allowed in this section", :allow_blank => true}            

  validates :password,            
            :length => {:in => 6..15, :message => 'should be between 6 and 15 characters'},
            :confirmation => true

  validates :password_confirmation,            
            :length => {:in => 6..15, :message => 'should be between 6 and 15 characters'}  

  validates :email,            
            :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/, :message => "Please enter a valid email. ex: johndoe@mail.com"},
            :length => {:maximum => 128, :message => "email should not exceed 128 characters"},
            :uniqueness => {:message => "Already registered"}

  validates :company,
            :length => {:maximum => 64, :message => "cannot exceed 64 charaters", :allow_blank => true}

  validates :address,
            :length => {:maximum => 512, :message => "cannot exceed 512 characters", :allow_blank => true}

  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end  

  def self.authenticate(email,password)
    user = User.find_by_email(email)
    if user
      expected_pwd = User.encrypted_password(password, user.salt)
      if expected_pwd != user.hashed_password
        user = nil
      end
    end
    user
  end

  def admin?
    self.user_type == "Admin"
  end

  def self.get_userlist_for_current_user(current_user)
    User.joins("JOIN groups_users UG ON users.id = UG.user_id").where("UG.group_id IN (SELECT DISTINCT group_id FROM groups_users where user_id = ?)",current_user).select("DISTINCT users.id user_id, users.name user_name")
  end

  private

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def self.encrypted_password(pwd,salt)
    string_to_hash = pwd + "takraw" + salt
    Digest::SHA2.hexdigest(string_to_hash)
  end
end
