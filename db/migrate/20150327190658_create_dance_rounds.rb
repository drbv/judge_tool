class CreateDanceRounds < ActiveRecord::Migration
  def change
    create_table :dance_rounds do |t|
      t.references :round, index: true, foreign_key: true
      t.boolean :started, default: false
      t.boolean :finished, default: false
      t.integer :position, index: true
      t.timestamps null: false
    end
  end
end
