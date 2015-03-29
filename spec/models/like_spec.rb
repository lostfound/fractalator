require 'rails_helper'
describe Like do
  before :each do
    @owner = User.create email: Faker::Internet.email
    @fractal = Fractal.create user: @owner
    @liker = User.create email: Faker::Internet.email
  end
  it "is valid when score is 1" do
    like = Like.new likeable: @fractal, user: @liker, score: 1
    expect(like).to be_valid
  end
  it "is valid when score is -1" do
    like = Like.new likeable: @fractal, user: @liker, score: -1
    expect(like).to be_valid
  end
  it "is invalid when score is nil" do
    like = Like.new likeable: @fractal, user: @liker, score: nil
    expect(like).to be_invalid
    expect(like.errors.has_key? :score).to eq(true)
  end
  it "is invalid when score is 0" do
    like = Like.new likeable: @fractal, user: @liker, score: 0
    expect(like).to be_invalid
    expect(like.errors.has_key? :score).to eq(true)
  end
  it "is invalid when score less than -1" do
    like = Like.new likeable: @fractal, user: @liker, score: -2
    expect(like).to be_invalid
    expect(like.errors.has_key? :score).to eq(true)
  end
  it "is invalid when score greater than 1" do
    like = Like.new likeable: @fractal, user: @liker, score: 2
    expect(like).to be_invalid
    expect(like.errors.has_key? :score).to eq(true)
  end
  it "is invalid when selflike" do
    like = Like.new likeable: @fractal, user: @owner, score: 1
    expect(like).to be_invalid
    expect(like.errors.has_key? :user).to eq(true)
  end

  describe "Likable" do
    %i[like_by dislike_by].each do |method|
      context "has method #{method} which" do
        it "returns Like" do
          expect(@fractal.like_by(@liker).class).to eq(Like)
        end
        it "returns invalid Like when liker is nil" do
          like = @fractal.try method, nil
          expect(like).to be_invalid
          expect(like.errors.has_key? :user).to eq(true)
        end
        if method == :like_by
          it "increased lakeable score by 1" do
            old_score = @fractal.score
            @fractal.like_by @liker
            expect(@fractal.score).to eq(old_score+1)
          end
          it "increased lakeable user's score by 1" do
            old_score = @fractal.user.score
            @fractal.like_by @liker
            expect(@fractal.user.score).to eq(old_score+1)
          end
        end
        if method == :dislike_by
          it "decreased lakeable score by 1" do
            old_score = @fractal.score
            @fractal.dislike_by @liker
            expect(@fractal.score).to eq(old_score-1)
          end
          it "decreased lakeable user's score by 1" do
            old_score = @fractal.user.score
            @fractal.dislike_by @liker
            expect(@fractal.user.score).to eq(old_score-1)
          end
        end
        it "return valid Like when user like likeable once" do
          expect(@fractal.like_by @liker).to be_valid
        end
        it "return invalid Like when user like likeable twice" do
          old_score = @fractal.score
          expect(@fractal.try(method, @liker)).to be_valid
          expect(@fractal.try(method, @liker)).to be_invalid
          expect(@fractal.try(method, @liker).class).to eq(Like)
          @fractal.reload
          expect(@fractal.score).not_to eq(old_score)
        end
      end
    end
  end
end

