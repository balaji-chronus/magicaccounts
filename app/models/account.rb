class Account < ActiveRecord::Base
  has_many :transactions
  belongs_to :group
  ACCOUNT_STATUS = ["Open", "Closed", "Under Review", "Blacklisted"]

  validates :name, :presence => {:message => 'Account name cannot be blank'},
                   :length => {:minimum => 6}

  validates :code, :presence  => {:message => 'Account code cannot be blank'},
            :uniqueness => {:message => 'Account code already exists'},
            :length => {:minimum => 4}

  validates :code, :length => {:maximum => 16}

  validates :status, :inclusion => ACCOUNT_STATUS  

end
