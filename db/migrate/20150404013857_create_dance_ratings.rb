class CreateDanceRatings < ActiveRecord::Migration
  def change
    create_table :dance_ratings do |t|
      t.integer :female_base_rating
      t.integer :female_turn_rating
      t.integer :male_base_rating
      t.integer :male_turn_rating
      t.integer :choreo_rating
      t.integer :dance_figure_rating
      t.integer :team_presentation_rating
      t.string :mistakes
      t.references :dance_team, index: true, foreign_key: true
      t.references :dance_round, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :dance_ratings, [:dance_round_id, :user_id], name: :find_by_judge_and_dance_round
  end
end
