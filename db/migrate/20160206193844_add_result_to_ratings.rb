class AddResultToRatings < ActiveRecord::Migration
  def change
    add_column :dance_round_mappings, :result, :decimal, precision: 6, scale: 4, default: 0
    add_column :dance_ratings, :result, :decimal, precision: 6, scale: 4, default: 0
    add_column :acrobatic_ratings, :result, :decimal, precision: 6, scale: 4, default: 0
    add_column :dance_round_ratings, :result, :decimal, precision: 6, scale: 4, default: 0
  end
end
