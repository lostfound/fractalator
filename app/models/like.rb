class Like < ActiveRecord::Base
  belongs_to :likeable, polymorphic: true
  belongs_to :user
  validates :user, presence: true
  after_save :update_scores
private
  def update_scores
    likeable.increment! :score, score
    user = likeable.try :user
    user.increment!(:score, score) if user
  end
end
