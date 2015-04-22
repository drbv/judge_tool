class CreateDanceRatings < ActiveRecord::Migration
  def change
    create_table :dance_ratings do |t|
      t.integer :female_base_rating, default: 0
      t.integer :female_turn_rating, default: 0
      t.integer :male_base_rating, default: 0
      t.integer :male_turn_rating, default: 0
      t.integer :choreo_rating, default: 0
      t.integer :dance_figure_rating, default: 0
      t.integer :team_presentation_rating, default: 0
      t.string :mistakes
      t.integer :reopened, default: 0
      t.references :dance_team, index: true, foreign_key: true
      t.references :dance_round, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :dance_ratings, [:dance_round_id, :user_id], name: :find_by_judge_and_dance_round
    add_index :dance_ratings, [:dance_round_id, :user_id, :reopened], name: :find_by_judge_and_dance_round_and_reopened
  end
end
