class CreateAcrobaticTypes < ActiveRecord::Migration
  def change
    create_table :acrobatic_types do |t|
      t.string :name
      t.string :short_name
      t.decimal :max_points, precision: 2, scale: 2
      t.integer :saftey_level
      t.timestamps null: false
    end
  end
end
