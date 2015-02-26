class RenameItratedFunctionSystemToFractal < ActiveRecord::Migration
  def change
    rename_table :iterated_function_systems, :fractals
    add_column :fractals, :type, :string, default: 'IteratedFunctionSystem'
    add_index :fractals, :type
  end
end
