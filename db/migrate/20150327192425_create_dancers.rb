class CreateDancers < ActiveRecord::Migration
  def change
    create_table :dancers do |t|
      t.string :first_name
      t.string :last_name
      t.integer :age

      t.timestamps null: false
    end
  end
end
