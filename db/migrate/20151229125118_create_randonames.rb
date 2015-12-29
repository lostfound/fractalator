class CreateRandonames < ActiveRecord::Migration
  def migrate direction
    super
    if direction == :up
      User.all.each {|user| Randoname.create! user: user}
    end
  end
  def change
    create_table :randonames do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.text :names
      t.integer :pos, default: 0

    end
  end
end
