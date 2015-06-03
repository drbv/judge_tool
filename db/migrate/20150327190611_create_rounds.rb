class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.references :round_type, index: true, foreign_key: true
      t.references :dance_class, index: true, foreign_key: true
      t.boolean :closed, default: false
      t.boolean :started, default: false
      t.integer :max_teams
      t.datetime :start_time, index: true
      t.integer :position, index: true
      t.timestamps null: false
      t.integer :rt_id
    end
    add_index :rounds, %i(started closed)
  end
end
