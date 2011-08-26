class User < ActiveRecord::Base  
  has_many :friendships  
  has_many :friends, :through => :friendships  
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"  
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user  
end

class Friendship < ActiveRecord::Base  
  belongs_to :user  
  belongs_to :friend, :class_name => 'User'  
end


class Step < ActiveRecord::Base  
  has_many :links  
  has_many :nexts, :through => :links  
  has_many :inverse_links, :class_name => "Link", :foreign_key => "next_id"  
  has_many :inverse_nexts, :through => :inverse_links, :source => :step  
end

class Link < ActiveRecord::Base  
  belongs_to :user  
  belongs_to :friend, :class_name => 'User'  
end
