module LikeableModel
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
