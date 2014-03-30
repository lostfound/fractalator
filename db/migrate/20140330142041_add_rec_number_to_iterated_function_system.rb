class AddRecNumberToIteratedFunctionSystem < ActiveRecord::Migration
  def change
    add_column :iterated_function_systems, :rec_number, :integer, default: 8
  end
end
