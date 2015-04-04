class CreateCreates < ActiveRecord::Migration
  def change
    create_table :creates do |t|
      t.string :Acrobatic
      t.string :name
      t.string :short_name
      t.decimal :max_points
      t.integer :saftey_level

      t.timestamps null: false
    end
  end
end
