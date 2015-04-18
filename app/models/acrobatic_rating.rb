class AcrobaticRating < ActiveRecord::Base
  include ReopenedAttributes
  belongs_to :acrobatic
  belongs_to :dance_team
  belongs_to :user

  validates_presence_of :dance_team, :acrobatic, :user, :rating
  validates_format_of :mistakes, with: /\A((S2|S10|S20|U2|U10|U20|V5)(,(S2|S10|S20|U2|U10|U20|V5))*)?\Z/
  validates_uniqueness_of :acrobatic_id, scope: %i[user_id dance_team_id]

  def permitted_attributes
    new_record? ? [:rating, :mistakes] : reopened_attributes
  end

  def reopen!(attributes)
    update_attribute :reopen, attributes.inject(0) {|memo, attr| memo += reopen_value(attr)}
  end

  def full_mistakes
    mistakes.blank? ? 'Keine Fehler' : mistakes
  end

  def punishment
    @punishment ||= mistakes.split(',').map {|malus| malus[1..-1].to_i}.sum
  end

  private

  def discussable_attributes
    %i[rating mistakes]
  end

end