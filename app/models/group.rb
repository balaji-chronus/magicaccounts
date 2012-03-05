class Group < ActiveRecord::Base
  has_and_belongs_to_many :users, :uniq => true
  has_many :accounts
  has_many :transactions, :through => :accounts
  has_many :comments, :as => :commentable
  belongs_to :user
  
  
  GROUPSTATUS = ["Enabled", "Disabled"]  
  
  validates :name, 
            :uniqueness => {:scope => :user_id, :message => 'Group name already taken by you. Choose another name'},
            :presence   => {:message => 'Group name cannot be blank'},
            :length     => {:in => 4..32, :message => "Name should be between 4 and 32 characters"},
            :format     => {:with => /^[a-zA-Z0-9]+[ a-zA-Z0-9_'-]*[a-zA-Z0-9]+$/, :message => 'Name must start and end with an alphabet or digit and can contain only alphanumeric, spaces, hyphens, apostrophes and underscores'}

  validates :status,
            :inclusion => { :in => GROUPSTATUS, :message => "please select Enabled or Disabled" }

  validates :user_id,
            :presence => {:message => 'user_id is mandatory'}#,
            #:inclusion => { :in => User.find(:all).map {|user| user.id}, :message => "user include is mandatory "}

  validates :code,
            :presence => {:message => "group code is mandatory"},
            :length   => {:maximum => 50 }

end
