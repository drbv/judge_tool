class CreateAcrobaticRatings < ActiveRecord::Migration
  def change
    create_table :acrobatic_ratings do |t|
      t.integer :rating, default: 0
      t.string :mistakes
      t.references :acrobatic, index: true, foreign_key: true
      t.references :dance_team, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :reopened, default: 0
      t.boolean :danced, default: false

      t.timestamps null: false
    end
    add_index :acrobatic_ratings, [:user_id, :acrobatic_id]
    add_index :acrobatic_ratings, [:user_id, :acrobatic_id, :reopened], name: 'reopened_user_acrobatic'
  end
end
