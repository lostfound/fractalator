class AddRastorToIteratedFunctionSystems < ActiveRecord::Migration
  def change
    add_column :iterated_function_systems, :image_thumb, :string
    add_column :iterated_function_systems, :image, :string
  end
end
