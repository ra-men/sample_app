class Micropost < ActiveRecord::Base
  attr_accessible :content

  belongs_to :user

  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true

  default_scope order: 'microposts.created_at DESC'
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  # def self.from_users_followed_by(user)
  #   if !user.followed_users.empty?
  #     followed_user_ids = user.followed_user_ids.join(', ')
  #     where("user_id IN (?) OR user_id = ?", followed_user_ids, user)
  #   else
  #     where("user_id = ?", user)
  #   end
  # end

  private
  
  def self.followed_by(user)
    where(%(   user_id IN (SELECT followed_id 
                             FROM relationships 
                            WHERE follower_id = :user_id) 
            OR user_id = :user_id), 
          { user_id: user })
  end

end
