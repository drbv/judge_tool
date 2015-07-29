class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login, index: true
      t.integer :licence
      t.integer :wr_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :pin
      t.string :name
      t.references :club, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
