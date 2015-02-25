class AddInvertToIteratedFunctionSystem < ActiveRecord::Migration
  def change
    add_column :iterated_function_systems, :invert, :boolean, default: false
  end
end
