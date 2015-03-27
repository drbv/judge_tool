class CreateDanceClasses < ActiveRecord::Migration
  def change
    create_table :dance_classes do |t|
      t.string :name
      t.integer :safety_level

      t.timestamps null: false
    end
  end
end
