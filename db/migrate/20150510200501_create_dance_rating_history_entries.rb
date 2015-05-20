class CreateDanceRatingHistoryEntries < ActiveRecord::Migration
  def change
    create_table :dance_rating_history_entries do |t|
      t.integer :female_base_rating, default: 0
      t.integer :female_turn_rating, default: 0
      t.integer :male_base_rating, default: 0
      t.integer :male_turn_rating, default: 0
      t.integer :choreo_rating, default: 0
      t.integer :dance_figure_rating, default: 0
      t.integer :team_presentation_rating, default: 0
      t.string :mistakes
      t.integer :reopened, default: 0
      t.boolean :final, default: false

      t.references :dance_rating, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
