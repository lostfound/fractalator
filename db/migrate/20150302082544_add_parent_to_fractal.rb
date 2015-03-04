class AddParentToFractal < ActiveRecord::Migration
  def change
    add_column :fractals, :parent_id, :integer, index: true
  end
end
