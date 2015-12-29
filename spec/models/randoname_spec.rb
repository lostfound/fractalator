require 'rails_helper'

RSpec.describe Randoname, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
  it "created automaticly afrer user creation" do
    user = create :user, name: nil
    expect(user.randoname).to be_present
  end
  it "changes names every 15 queries" do
    user = create :user, name: nil
    randoname = user.randoname
    allnames = []
    100.times do
      curnames = randoname.get_names
      allnames+=curnames
      curnames.each do |name|
        expect( randoname.is_name_valid? name ).to be true
      end
    end
    expect(allnames.uniq.length).to eq 1000

  end
end
