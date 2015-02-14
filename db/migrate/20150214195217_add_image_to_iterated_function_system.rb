class AddImageToIteratedFunctionSystem < ActiveRecord::Migration
  def change
    add_column :iterated_function_systems, :image, :text
    add_column :iterated_function_systems, :image_url, :string
  end
end
