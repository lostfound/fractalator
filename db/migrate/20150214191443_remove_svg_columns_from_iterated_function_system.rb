class RemoveSvgColumnsFromIteratedFunctionSystem < ActiveRecord::Migration
  def change
    remove_column :iterated_function_systems, :image_thumb, :string
    remove_column :iterated_function_systems, :image, :string
  end
end
