module Likeable
  def self.included(base)
    base.class_eval do
      has_many :likes, as: :likeable
      scope :likest, ->{order "score desc"}
      def self.can_user_like user, ids
        return Hash.new(false) if user.nil?
        class_name = superclass == ActiveRecord::Base ? name : superclass.name
        _ids = ids.is_a?(Array) ? ids : [ids]
        user.likes.where(likeable_type: class_name, likeable_id: _ids).inject(Hash.new(true)) do |h, like|
          h[like.likeable_id] = false
          h
        end
      end
    end
  end
  def like_by u
    score_by u, 1
  end

  def dislike_by u
    score_by u, -1
  end
  def score_by u, points
    like = likes.create user: u, score: points
    reload if like.valid?
    like
  end
end
