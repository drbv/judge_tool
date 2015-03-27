class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.references :round_type, index: true, foreign_key: true
      t.references :dance_class, index: true, foreign_key: true
      t.datetime :start_time

      t.timestamps null: false
    end
  end
end
