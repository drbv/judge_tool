class Round < ActiveRecord::Base
  resourcify
  belongs_to :round_type
  belongs_to :dance_class
  has_many :dance_rounds
  require 'uri'

  def self.active
    where(started: true, closed: false).first
  end

  def self.judge_role_for(index)
    case index
      when 0
        :observer
      when (1..((User.count - 1) / 2))
        :acrobatics_judge
      else
        :dance_judge
    end
  end

  def has_no_acrobatics?
    (self.round_type.name.include? 'Fuß') || (self.dance_class.name.include? 'Schüler')
  end

  def active?
    started? && !closed?
  end

  def started?
    started
  end

  def start!
    self.started = true
    self.start_time = Time.now
    save
  end

  def closed?
    closed
  end

  def close!
    update_attribute :closed, true
    generate_rating_export_file
  end

  def judges
    @judges ||= observers + dance_judges + acrobatics_judges
  end

  def dance_judges
    User.with_role :dance_judge, self
  end

  def acrobatics_judges
    User.with_role :acrobatics_judge, self
  end

  def observer
    User.with_role(:observer, self).first
  end

  def observers
    User.with_role :observer, self
  end

  def generate_rating_export_file
    file_name="T#{self.tournament_number}_RT#{self.rt_id}.txt"
    File.write(Rails.root.join('tmp', file_name), '')

    dance_rounds.each do |dance_round|
      dance_round.dance_ratings.select { |dance_rating| dance_rating.user.is_judge? dance_rating.dance_round.round }.group_by(&:user).each do |user, dance_ratings|
        dance_ratings = dance_ratings.sort_by { |dance_rating| dance_rating.dance_team.startnumber }
        @rating_line_dance_part2 = rating_line_dance_part2 dance_ratings

        dance_ratings.each do |dance_rating|
          File.open(Rails.root.join('tmp', file_name), 'a') do |f|
            f << "#{dance_rating.dance_team.access_db_id};#{dance_rating.user.wr_id};#{@rating_line_dance_part2}\n"
          end
        end
      end
    end
  end

  def rating_line_dance_part2(dance_ratings)
    "#{rating_line_long_ids dance_ratings}&#{rating_line_dance dance_ratings}#{rating_line_acrobatic_placeholder dance_ratings}&#{rating_line_dance_mistakes dance_ratings}&#{rating_line_time}"
  end

  def rating_line_long_ids (dance_ratings)

    line = URI.encode_www_form PR_ID1: dance_ratings.first.dance_team.access_db_id,
                               nPage: 'judge_tool',
                               rh1: dance_ratings.first.dance_round.position,
                               WR_ID: dance_ratings.first.user.wr_id,
                               rt_ID: self.rt_id
    if dance_ratings.count == 2
      line << "&#{URI.encode_www_form PR_ID2: dance_ratings.last.dance_team.access_db_id,
                                      rh2: dance_ratings.first.dance_round.position}"
    elsif dance_ratings.count > 2
      fail()
    end
    return line
  end

  def rating_line_dance (dance_ratings)
    dance_ratings.map.with_index do |dance_rating, index|
      URI.encode_www_form "wsh_#{index + 1}" => dance_rating.male_base_rating_points,
                          "wth_#{index + 1}" => dance_rating.male_turn_rating_points,
                          "wsd_#{index + 1}" => dance_rating.female_base_rating_points,
                          "wtd_#{index + 1}" => dance_rating.female_turn_rating_points,
                          "wch_#{index + 1}" => dance_rating.choreo_rating_points,
                          "wtf_#{index + 1}" => dance_rating.dance_figure_rating_points,
                          "wda_#{index + 1}" => dance_rating.team_presentation_rating_points
    end.join('&')
  end

  def rating_line_acrobatic_placeholder (dance_ratings)
    if dance_ratings.first.dance_round.acrobatic_ratings.empty?
      return ''
    else
      "&#{rating_line_acrobatic_for_dance dance_ratings}"
    end
  end

  def rating_line_acrobatic_for_dance (dance_ratings)
    dance_ratings.map.with_index do |dance_rating, index_dance_team|
      dance_rating.dance_round.acrobatics.where(dance_team_id: dance_rating.dance_team_id).map.with_index do |acrobatic, index_acrobatic|
        URI.encode_www_form "wfl#{index_dance_team + 1}_ak#{index_dance_team + 1}#{index_acrobatic + 1}" => '',
                            "tfl#{index_dance_team + 1}_ak#{index_dance_team + 1}#{index_acrobatic + 1}" => '',
                            "wak#{index_dance_team + 1}#{index_dance_team + 1}" => ''
      end.join('&')
    end.join('&')
  end

  def rating_line_dance_mistakes (dance_ratings)
    line = ""
    dance_ratings.map.with_index do |dance_rating, index|
      line << "tfl#{index+1}=#{dance_rating.mistakes.to_s.tr(',',' ') || ''}&wfl#{index+1}=#{dance_rating.punishment}"
    end.join('&')
  end

  def rating_line_time
    "wtim=#{Time.now.strftime('%H_%M_%S;%H:%M:%S')}"
  end

  # def set_random_judges
  #   User.with_role(:judge).order(ActiveRecord::Base.connection.instance_values["config"][:adapter].start_with?('mysql') ? 'RAND()' : 'RANDOM()').each_with_index do |user, index|
  #     user.add_role Round.judge_role_for(index), self
  #   end if dance_class
  # end

end
