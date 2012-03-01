class Group < ActiveRecord::Base
  has_and_belongs_to_many :users, :uniq => true
  has_many :accounts
  has_many :comments, :as => :commentable
  
  GROUPSTATUS = ["Enabled", "Disabled"]  
  
  validates :name, 
            #:uniqueness => {:message => 'Group name already taken. Choose another name'},
            :presence   => {:message => 'Group name cannot be blank'},
            :length     => {:minimum => 4, :maximum => 16}

  validates_inclusion_of :status, :in => GROUPSTATUS

end
