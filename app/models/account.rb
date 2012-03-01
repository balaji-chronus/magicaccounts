class Account < ActiveRecord::Base
  has_many :transactions
  belongs_to :group
  has_many :comments, :as => :commentable
  
  
  ACCOUNT_STATUS = ["Open", "Closed", "Under Review", "Blacklisted"]

  validates :name, :presence => {:message => 'Account name cannot be blank'},
                   :length => {:minimum => 6}

  validates :code, :presence  => {:message => 'Account code cannot be blank'},
            :uniqueness => {:message => 'Account code already exists'},
            :length => {:minimum => 4}

  validates :code, :length => {:maximum => 16}

  validates :status, :inclusion => ACCOUNT_STATUS

  validates_inclusion_of :group_id, :in => Group.find(:all).map {|grp| grp.id}, :message => "Select a group from the list"

end
