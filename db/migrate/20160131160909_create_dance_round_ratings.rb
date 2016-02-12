class CreateDanceRoundRatings < ActiveRecord::Migration
  def change
    create_table :dance_round_ratings do |t|
      t.string :mistakes
      t.references :dance_team, index: true, foreign_key: true
      t.references :dance_round, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
