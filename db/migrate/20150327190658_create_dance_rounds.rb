class CreateDanceRounds < ActiveRecord::Migration
  def change
    create_table :dance_rounds do |t|
      t.references :round, index: true, foreign_key: true
      t.datetime :started_at
      t.datetime :finished_at
      t.boolean :started, default: false
      t.boolean :finished, default: false
      t.integer :position, index: true
      t.timestamps null: false
    end

    add_index :dance_rounds, [:finished, :started]
  end
end
