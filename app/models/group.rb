class Group < ActiveRecord::Base
  has_and_belongs_to_many :users, :uniq => true
  has_many :transactions, :dependent => :destroy
  has_many :comments
  belongs_to :user
  
  module GROUPSTATUS
    ENABLED = "Enabled"
    DISABLED = "Disabled"
    ALL = [ENABLED, DISABLED]  
  end

  validates :name, 
            :uniqueness => {:scope => :user_id, :message => 'Group name already taken by you. Choose another name'},
            :presence   => {:message => 'Group name cannot be blank'},
            :length     => {:in => 4..32, :message => "Name should be between 4 and 32 characters"},
            :format     => {:with => /^[a-zA-Z0-9]+[ a-zA-Z0-9_'-]*[a-zA-Z0-9]+$/, :message => 'Name must start and end with an alphabet or digit and can contain only alphanumeric, spaces, hyphens, apostrophes and underscores'}

  validates :status,
            :inclusion => { :in => GROUPSTATUS::ALL, :message => "please select Enabled or Disabled" }

  validates :user_id,
            :presence => {:message => 'user_id is mandatory'}#,
            #:inclusion => { :in => User.find(:all).map {|user| user.id}, :message => "user include is mandatory "}

  validates :code,
            :presence => {:message => "group code is mandatory"},
            :length   => {:maximum => 50 }

  def self.get_user_owned_groups(current_user)
    Group.find_all_by_user_id(current_user)
  end

  def self.get_groups_for_current_user(current_user)
      Group.where(" id IN (SELECT DISTINCT group_id FROM groups_users where user_id = ?)",current_user)
  end

  def user_attributes=(user_attributes)
    self.users = []
    user_attributes.each do |key, attributes|
      user = User.find_by_email(attributes[:email])
      unless user
        user = User.new(attributes)
        user.password = (0...8).map{ ('a'..'z').to_a[rand(26)] }.join
        user.password_confirmation = user.password
        user.invite_status = User::INVITE_STATUS::NOT_REGISTERED
        user.save!
      end
      self.users << user
    end
  end
end
