class AddBaseShapeToIteratedFunctionSystem < ActiveRecord::Migration
  def change
    add_column :iterated_function_systems, :base_shape, :integer, default: 0
  end
end
