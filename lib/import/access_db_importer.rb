require 'mdb'

module MS
  class AccessDbImporter
    class FileNotFound < StandardError
    end

    def initialize
      guess_database
      raise FileNotFound.new("File at #{@path} not found!") unless File.exists?(@path)
      @access_database = Mdb.open @path
    end

    def import_persons!
      import_officials
      import_dance_teams
    end

    def import_round!
      @round_created=false
      @access_database['Rundentab'].sort_by { |round| round[:Rundenreihenfolge].to_i }.each do |round|
        next if !@round_created && find_round(round)
        @round_created = true
        create_round(round)
      end
      nil
    end

    def dance_rounds_available?(round)
      if dance_rounds(round).count > 0
        true
      else
        false
      end
    end

    def round_dance_teams_elected?(round)
      elected = true
      # find all lines from this round

      @access_database[:Paare_Rundenqualifikation].select{|quali| quali[:RT_ID].to_i == round.rt_id}.each do |dance_round_line|
        #check if the Team is has no roundnumber but is available.
        if (dance_round_line[:Rundennummer].to_i <= 0   && dance_round_line[:Anwesend_Status].to_i == 1)
          elected = false
        end
      end
      elected
    end

    def import_dance_rounds!(round)
      observers = round.observers.order(:licence).to_a
      dance_rounds(round).each do |dance_round_no, dance_teams|
        dance_round = round.dance_rounds.build position: dance_round_no
        dance_teams.map { |dance_round_data| DanceTeam.find_by access_db_id: dance_round_data[:TP_ID] }.
            sort_by(&:startnumber).each_with_index do |team, index|
          team_data = @access_database[:Paare].select { |team_data| team_data[:TP_ID].to_i == team.access_db_id }.first
          dance_round.dance_round_mappings.build dance_team_id: team.id
          8.times do |k|
            next if team_data[:"Akro#{k+1}_#{round.round_type.acrobatics_from}"].blank?
            dance_round.acrobatics.build dance_team: team,
                                         acrobatic_type: acrobatic_type(team_data[:"Akro#{k+1}_#{round.round_type.acrobatics_from}"], team_data[:"Wert#{k+1}_#{round.round_type.acrobatics_from}"])
          end
        end
        dance_round.save
      end
    end

    def acrobatic_type(short_name, value)
      if @acrobatic_type = AcrobaticType.find_by(short_name: short_name, max_points: value.to_f.to_d.round(2))
        @acrobatic_type
      else
        AcrobaticType.create short_name: short_name, max_points: value.to_f.to_d.round(2)
      end
    end

    def dance_rounds(round)
      @access_database[:Paare_Rundenqualifikation].select do |dance_round|
        dance_round[:RT_ID] == rt_id(round) && dance_round[:Anwesend_Status].to_i == 1
      end.sort_by { |dance_round| dance_round[:Rundennummer].to_i }.group_by { |dance_round| dance_round[:Rundennummer].to_i }
    end

    def rt_id(round)
      @access_database[:Rundentab].select { |rt| rt[:Rundenreihenfolge].to_i == round.position }.first[:RT_ID]
    end

    def find_round(round)
      Round.find_by dance_class_id: (round[:Startklasse] && dance_classes[round[:Startklasse].to_sym].id),
                    round_type_id: (round_types[round[:Runde].to_sym].id)
    end

    def create_round(round)
      @round = Round.create dance_class_id: (round[:Startklasse] && dance_classes[round[:Startklasse].to_sym].id),
                            round_type_id: (round_types[round[:Runde].to_sym].id),
                            start_time: start_time_from(round[:Startzeit]),
                            position: round[:Rundenreihenfolge].to_i,
                            rt_id: round[:RT_ID],
                            tournament_number: @access_database[:Turnier].first[:Turnier_Nummer],
                            max_teams: round[:Anz_Paare].to_i
      @access_database[:Startklasse_Wertungsrichter].select { |mapping| mapping[:Startklasse] == round[:Startklasse] }.each do |judge_role|
        next if judge_role[:WR_function] == 'X'
        next if judge_role[:WR_function] == 'Ak' and @round.has_no_acrobatics?
        judge = User.find_by licence: @access_database[:Wert_Richter].select { |wr| wr[:WR_ID] == judge_role[:WR_ID] }.first[:WR_Lizenznr]
        judge.add_role translate_role(judge_role[:WR_function]), @round
      end
    end

    def start_time_from(start_time)
      if start_time
        start_time.gsub('1899', Time.now.year.to_s).to_time
      else
        Time.now
      end
    end

    def translate_role(mdb_role_name)
      case mdb_role_name
        when 'Ak'
          :acrobatics_judge
        when 'Ft'
          :dance_judge
        when 'Ob'
          :observer
        else
          fail 'not expected access database entry!'
      end
    end

    def round_types
      @round_types ||= Hash[fixed_dance_round_types + dancing_dance_round_types]
    end

    def dance_classes
      @dance_classes ||= Hash[@access_database[:Startklasse].map { |dance_class| [dance_class[:Startklasse].to_sym, create_dance_class(dance_class)] }]
    end

    def fixed_dance_round_types
      @access_database[:Tanz_Runden_erg].map { |round| [round[:Runde].to_sym, create_round_type(round, true)] }
    end

    def dancing_dance_round_types
      @access_database[:Tanz_Runden_fix].map { |round| [round[:Runde].to_sym, create_round_type(round, false)] }
    end

    def create_round_type(round, no_dance)
      @round_type = RoundType.find_by name: round[:Rundentext]
      @round_type = RoundType.create name: round[:Rundentext], no_dance: no_dance,
                                     acrobatics_from: (round[:R_IS_ENDRUNDE] == '1' ? 'ER' : (%w(Vor_r Hoff_r).include?(round[:Runde]) ? 'VR' : 'ZR')) unless @round_type
      @round_type
    end

    def create_dance_class(dance_class)
      @dance_class = DanceClass.find_by name: dance_class[:Startklasse_text]
      @dance_class = DanceClass.create name: dance_class[:Startklasse_text] unless @dance_class
      @dance_class
    end

    def import_officials
      update_admin
      create_judges
    end

    def update_admin
      @access_database[:Turnierleitung].select { |person| person[:Art] == 'TL' }.first.tap do |admin_data|
        admin = User.find_by(login: 'admin')
        if club = Club.find_by(number: admin_data[:Vereinsnr])
          admin.club = club
        end
        admin.update_attributes first_name: admin_data[:TL_Vorname], last_name: admin_data[:TL_Nachname], licence: admin_data[:Lizenznr]
        admin.generate_credentials
        admin.save
      end
    end

    def create_judges
      @access_database[:Wert_Richter].each do |judge_data|
        judge = User.new(first_name: judge_data[:WR_Vorname], last_name: judge_data[:WR_Nachname], licence: judge_data[:WR_Lizenznr], wr_id: judge_data[:WR_ID])
        if club = Club.find_by(number: judge_data[:Vereinsnr])
          judge.club = club
        end
        judge.add_role judge_data[:WR_Azubi] == '0' ? :judge : :trainee
        judge.save
      end
    end

    def import_dance_teams
      puts "Starting to import dance_teams\n"
      dance_teams = []
      @access_database[:Paare].each do |team|
        dance_team = DanceTeam.new
        dance_team.name = team[:Name_Team]
        dance_team.startbook_number = team[:Startbuch]
        dance_team.startnumber = team[:Startnr]
        dance_team.dancers.build first_name: team[:He_Vorname], last_name: team[:He_Nachname], age: team[:He_Alterskontrolle] unless team[:He_Nachname].blank?
        dance_team.dancers.build first_name: team[:Da_Vorname], last_name: team[:Da_Nachname], age: team[:Da_Alterskontrolle] unless team[:Da_Nachname].blank?
        if club = Club.find_by(number: team[:Verein_nr])
          dance_team.club = club
        else
          dance_team.build_club name: team[:Verein_Name], number: team[:Verein_nr]
        end
        dance_team.access_db_id = team[:TP_ID]
        dance_team.save
        dance_teams << dance_team
      end
      puts "#{dance_teams.size} DanceTeams imported\n"
    end

    def guess_database
      mdb_files_in_tmp = Dir.glob(File.join(Rails.root, 'tmp/*.mdb'))
      @path = if mdb_files_in_tmp.size==1
                puts "Load mdb from: #{mdb_files_in_tmp.first}"
                mdb_files_in_tmp.first
              else
                fail 'Datenbank nicht gefunden'
              end
    end
  end
end