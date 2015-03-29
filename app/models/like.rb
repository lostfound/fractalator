class Like < ActiveRecord::Base
  belongs_to :likeable, polymorphic: true
  belongs_to :user
  validates :user, presence: true
  validates :user_id, uniqueness: {scope: :likeable}
  validates :score, inclusion: {in: [-1,1]}
  validate :self_like_not_allowed
  after_save :update_scores
private
  def self_like_not_allowed
    if likeable.try(:user) == user
      errors.add(:user, "Self like is not allowed")
    end
  end

  def update_scores
    likeable.increment! :score, score
    user = likeable.try :user
    user.increment!(:score, score) if user
  end
end
