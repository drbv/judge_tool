class CreateAcrobaticRatings < ActiveRecord::Migration
  def change
    create_table :acrobatic_ratings do |t|
      t.integer :rating
      t.string :mistakes
      t.references :acrobatic, index: true, foreign_key: true
      t.references :dance_team, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
