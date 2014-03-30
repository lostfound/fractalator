class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :likeable, polymorphic: true, index: true
      t.belongs_to :user, index: true
      t.integer :score, default: 1

      t.timestamps
    end
    add_index :likes, [:likeable_id, :likeable_type, :user_id], unique: true
  end
end
