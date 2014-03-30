class CreateIteratedFunctionSystems < ActiveRecord::Migration
  def change
    create_table :iterated_function_systems do |t|
      t.belongs_to :user, index: true
      t.string :name
      t.text :description
      t.text :transforms

      t.timestamps
    end
  end
end
