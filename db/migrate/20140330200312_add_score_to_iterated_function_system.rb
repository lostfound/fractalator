class AddScoreToIteratedFunctionSystem < ActiveRecord::Migration
  def change
    add_column :iterated_function_systems, :score, :integer, default: 0
  end
end
