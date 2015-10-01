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
      # getting all dance ratings of one dance_round grouped by user. Normally each Judge has max 2 Dance_Teams
      dance_round.export_dance_ratings(dance_round).group_by(&:user).each do |user, dance_ratings|
        dance_ratings = dance_ratings.sort_by { |dance_rating| dance_rating.dance_team.startnumber }
        @rating_line_dance_part2 = rating_line_dance_part2 dance_ratings

        dance_ratings.each do |dance_rating|
          File.open(Rails.root.join('tmp', file_name), 'a') do |f|
            f << "#{dance_rating.dance_team.access_db_id};#{user.wr_id};#{@rating_line_dance_part2}\n"
          end
        end
      end
      if (!self.has_no_acrobatics?)

        #get all acrobatic ratings for this dance_round. This will be one per acrobatic
        dance_round.export_acrobatic_ratings(dance_round).group_by(&:user).each do |user, acrobatic_ratings|
          #sort acrobatic ratings by dance_team and  on position
          acrobatic_ratings = acrobatic_ratings.sort_by { |acro_rating| [acro_rating.dance_team.startnumber, acro_rating.acrobatic.position] }
          @rating_line_acrobatic_part2 = rating_line_acrobatic_part2 acrobatic_ratings
          dance_teams=acrobatic_ratings.map(&:dance_team).uniq.sort_by { |dance_team| dance_team.startbook_number }

          dance_teams.each do |dance_team|
            File.open(Rails.root.join('tmp', file_name), 'a') do |f|
              f << "#{dance_team.access_db_id};#{user.wr_id};#{@rating_line_acrobatic_part2}\n"
            end
          end
        end
      end
    end
  end

  def rating_line_acrobatic_part2(acrobatic_ratings)
    dance_teams=acrobatic_ratings.map(&:dance_team).uniq.sort_by { |dance_team| dance_team.startnumber }

    line = rating_line_long_ids_acrobatic acrobatic_ratings , dance_teams
    line << "&#{rating_line_dance_placeholder dance_teams}"
    line << "&#{rating_line_acrobatic acrobatic_ratings}"
    line << "#{acrobatic_mistakes_summary acrobatic_ratings , dance_teams}"
    line << "&#{rating_line_time}"

    return line
  end

  def acrobatic_mistakes_summary (acrobatic_ratings, dance_teams)
    line=''
    dance_teams.each.with_index do |dance_team, index_dance_team|
      line<< "&tfl#{index_dance_team+1}="
      mistakes_summary=0
      acrobatic_ratings.select { |rating| rating.dance_team_id == dance_team.id }.each do |acrobatic_rating|
        mistakes_summary+= acrobatic_rating.punishment
        line << "#{acrobatic_rating.mistakes.tr(',', ' ') || ''} "
      end
      line<<"&wfl#{index_dance_team+1}=#{mistakes_summary}"
    end
    return line
  end

  def rating_line_long_ids_acrobatic (acrobatic_ratings ,dance_teams)

    line = URI.encode_www_form PR_ID1: dance_teams.first.access_db_id,
                               nPage: 'judge_tool',
                               rh1: acrobatic_ratings.first.dance_round.position,
                               WR_ID: acrobatic_ratings.first.user.wr_id,
                               rt_ID: self.rt_id
    if dance_teams.count == 2
      line << "&#{URI.encode_www_form PR_ID2: dance_teams.last.access_db_id,
                                      rh2: acrobatic_ratings.last.dance_round.position}"
    elsif dance_teams.count > 2
      fail()
    end
    return line
  end

  def rating_line_acrobatic (acrobatic_ratings)
    line = ''
    acrobatic_ratings.map(&:dance_team).uniq.sort_by { |dance_team| dance_team.startnumber }.map.with_index do |dance_team, index_dance_team|
      # iterate over each acrobatic_rating for the given Dance_team
      acrobatic_ratings.select { |rating| rating.dance_team_id == dance_team.id }.map.with_index do |acrobatic_rating, index_acrobatic|
        URI.encode_www_form "wfl#{index_dance_team + 1}_ak#{index_dance_team + 1}#{index_acrobatic + 1}" => acrobatic_rating.punishment,
                            "tfl#{index_dance_team + 1}_ak#{index_dance_team + 1}#{index_acrobatic + 1}" => acrobatic_rating.mistakes.to_s.tr(',', ' ') || '',
                            "wak#{index_dance_team + 1}#{index_acrobatic + 1}" => acrobatic_rating.points_without_punishment
      end.join('&')
    end.join('&')
  end

  def rating_line_dance_part2(dance_ratings)
    "#{rating_line_long_ids_dance dance_ratings}&#{rating_line_dance dance_ratings}#{rating_line_acrobatic_placeholder dance_ratings}&#{rating_line_dance_mistakes dance_ratings}&#{rating_line_time}"
  end

  def rating_line_long_ids_dance (dance_ratings)

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
    if self.has_no_acrobatics?
      return ''
    else
      "&#{rating_line_acrobatic_for_dance dance_ratings}"
    end
  end

  def rating_line_dance_placeholder (dance_teams)
    dance_teams.map.with_index do |dance_team, index|
      URI.encode_www_form "wsh_#{index + 1}" => '',
                          "wth_#{index + 1}" => '',
                          "wsd_#{index + 1}" => '',
                          "wtd_#{index + 1}" => '',
                          "wch_#{index + 1}" => '',
                          "wtf_#{index + 1}" => '',
                          "wda_#{index + 1}" => ''
    end.join('&')

  end

  def rating_line_acrobatic_for_dance (dance_ratings)
    dance_ratings.map.with_index do |dance_rating, index_dance_team|
      dance_rating.dance_round.acrobatics.where(dance_team_id: dance_rating.dance_team_id).map.with_index do |acrobatic, index_acrobatic|
        URI.encode_www_form "wfl#{index_dance_team + 1}_ak#{index_dance_team + 1}#{index_acrobatic + 1}" => '0',
                            "tfl#{index_dance_team + 1}_ak#{index_dance_team + 1}#{index_acrobatic + 1}" => '',
                            "wak#{index_dance_team + 1}#{index_acrobatic + 1}" => ''
      end.join('&')
    end.join('&')
  end

  def rating_line_dance_mistakes (dance_ratings)
    dance_ratings.map.with_index do |dance_rating, index|
      "tfl#{index+1}=#{dance_rating.mistakes.to_s.tr(',', ' ') || ''}&wfl#{index+1}=#{dance_rating.punishment}"
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
