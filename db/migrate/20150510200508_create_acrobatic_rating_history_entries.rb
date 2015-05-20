class CreateAcrobaticRatingHistoryEntries < ActiveRecord::Migration
  def change
    create_table :acrobatic_rating_history_entries do |t|
      t.integer :rating, default: 0
      t.string :mistakes
      t.boolean :danced, default: false
      t.integer :reopened, default: 0

      t.references :acrobatic_rating, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
