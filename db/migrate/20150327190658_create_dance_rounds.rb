class CreateDanceRounds < ActiveRecord::Migration
  def change
    create_table :dance_rounds do |t|
      t.references :round, index: true, foreign_key: true
      t.boolean :finished, default: false

      t.timestamps null: false
    end
  end
end
