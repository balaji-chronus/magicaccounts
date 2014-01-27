class Contact < ActiveRecord::Base
	belongs_to :user
	attr_accessible :email, :name, :user_id
	validates :email,:uniqueness => {:scope => :user_id}
	validates :user_id, :presence => true
	validates :name, :presence => true
end

