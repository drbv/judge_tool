class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login
      t.string :licence
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_digest
      t.string :name
      t.references :club, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
