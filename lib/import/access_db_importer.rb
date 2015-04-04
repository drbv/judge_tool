require 'mdb'

module MS
  class AccessDbImporter
    class FileNotFound < StandardError
    end

    def initialize()
      guess_database
      raise FileNotFound.new("File at #{@path} not found!") unless File.exists?(@path)
      @access_database = Mdb.open @path
    end

    def import
      import_dance_teams
      import_rounds
    end

    def import_rounds
      binding.pry
      @access_database['Rundentab'].sort_by {|round| round[:Rundenreihenfolge].to_i}.each do |round|

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
                puts "Cannot find .mdb file in tmp directory. Please tell me the full path to .mdb file, that I shall process:\n"
                STDIN.gets
              end
    end
  end
end