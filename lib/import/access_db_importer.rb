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
      @access_database['Rundentab'].sort_by { |round| round[:Rundenreihenfolge].to_i }.each do |round|
        next if find_round(round)
        return create_round(round)
      end
      nil
    end

    def find_round(round)
      Round.find_by dance_class_id: (round[:Startklasse] && dance_classes[round[:Startklasse].to_sym].id),
                    round_type_id: (round_types[round[:Runde].to_sym].id)
    end

    def create_round(round)
      Round.create dance_class_id: (round[:Startklasse] && dance_classes[round[:Startklasse].to_sym].id),
                   round_type_id: (round_types[round[:Runde].to_sym].id),
                   start_time: round[:Startzeit].gsub('1899', Time.now.year.to_s).to_time
    end

    def round_types
      @round_types ||= Hash[(@access_database[:Tanz_Runden_erg] + @access_database[:Tanz_Runden_fix]).map { |round| [round[:Runde].to_sym, create_round_type(round)] }]
    end

    def dance_classes
      @dance_classes ||= Hash[@access_database[:Startklasse].map { |dance_class| [dance_class[:Startklasse].to_sym, create_dance_class(dance_class)] }]
    end

    def create_round_type(round)
      @round_type = RoundType.find_by name: round[:Rundentext]
      @round_type = RoundType.create name: round[:Rundentext] unless @round_type
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
      end
    end

    def create_judges
      @access_database[:Wert_Richter].each do |judge_data|
        judge = User.new(first_name: judge_data[:WR_Vorname], last_name: judge_data[:WR_Nachname], licence: judge_data[:WR_Lizenznr])
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
        dance_team.name = team[:Team_Name]
        dance_team.startbook_number = team[:Startbuch]
        dance_team.startnumber = team[:Startnr]
        dance_team.dancers.build first_name: team[:He_Vorname], last_name: team[:He_Nachname], age: team[:He_Alterskontrolle]
        dance_team.dancers.build first_name: team[:Da_Vorname], last_name: team[:Da_Nachname], age: team[:Da_Alterskontrolle]
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