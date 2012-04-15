class Account < ActiveRecord::Base
  has_many :transactions, :dependent => :destroy
  belongs_to :group
  belongs_to :user
  has_many :comments, :as => :commentable
  
  ACCOUNT_STATUS = ["Open", "Closed", "Under Review", "Blacklisted"]

  validates :name,
            :presence => {:message => 'Account name cannot be blank'},
            :length => {:in => 6..32, :message => "should be between 6 and 32 chars"},
            :uniqueness => { :scope => :group_id, :message => "There is already an account with this name for this group"}

  validates :code,
            :presence  => {:message => 'Account code cannot be blank'},
            :uniqueness => {:message => 'Account code already exists'},
            :length => {:in => 4..12, :message => "must be between 4 and 12 chars"}  

  validates :status, 
            :inclusion => ACCOUNT_STATUS,
            :presence => true

  validates :group_id, :existence => true
end
