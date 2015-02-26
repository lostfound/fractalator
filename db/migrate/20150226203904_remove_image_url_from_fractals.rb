class RemoveImageUrlFromFractals < ActiveRecord::Migration
  def change
    remove_column :fractals, :image_url, :string
  end
end
