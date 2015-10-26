class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.integer :chain_id
      t.belongs_to :fractal, index: true, foreign_key: true
      t.integer :repeats, default: 1, null: false
      t.integer :ordernum

      t.timestamps null: false
    end
    add_index :parts, :chain_id
  end
end
